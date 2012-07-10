module Ashton
  class Shader
    INVALID_LOCATION = -1
    MIN_OPENGL_VERSION = 2.0

    INCLUDE_PATH = File.expand_path "../shaders/include", __FILE__
    SHADER_PATH = File.expand_path "../shaders", __FILE__
    FRAGMENT_EXTENSION = ".frag"
    VERTEX_EXTENSION = ".vert"

    # List of built-in functions.
    BUILT_IN_FUNCTIONS = Dir[File.join(INCLUDE_PATH, "*.glsl")].map do |filename|
      filename =~ /(\w+)\.glsl/
      $1.to_sym
    end

    attr_reader :image

    # Instead of passing in source code, a file-name will be loaded or use a symbol to choose a built-in shader.
    #
    # `#include` will be recursively replaced in the source.
    #
    # * `#include <noise>` will load the built-in shader function, shaders/include/noise.glsl
    # * `#include "/home/spooner/noise.glsl"` will include that file, relative to the current working directory, NOT the source file.
    #
    # @option options [String, Symbol] :vertex Source code for vertex shader.
    # @option options [String, Symbol] :vert equivalent to :vertex
    # @option options [String, Symbol] :fragment Source code for fragment shader.
    # @option options [String, Symbol] :frag equivalent to :fragment
    def initialize(options = {})
      unless GL.version_supported? MIN_OPENGL_VERSION
        raise NotSupportedError, "Ashton requires OpenGL #{MIN_OPENGL_VERSION} support to utilise shaders"
      end

      vertex = options[:vertex] || options[:vert] || :default
      fragment = options[:fragment] || options[:frag] || :default

      @vertex_source = process_source vertex, VERTEX_EXTENSION
      @fragment_source = process_source fragment, FRAGMENT_EXTENSION

      @uniform_locations = {}
      @attribute_locations = {}
      @program = nil
      @image = nil
      @color = [1, 1, 1, 1]

      # Actually compile and link.
      @vertex = compile GL_VERTEX_SHADER, @vertex_source
      @fragment = compile GL_FRAGMENT_SHADER, @fragment_source
      link

      # In case we are using '#version 130' or higher, set out own color output.
      glBindFragDataLocationEXT @program, 0, "out_FragColor"

      use do
        # GL_TEXTURE0 will be activated later.
        glUniform1i glGetUniformLocation(@program, "in_Texture"), 0

        # These are optional, and only really make sense in post-processing shaders.
        glUniform1i glGetUniformLocation(@program, "in_WindowWidth"), $window.width
        glUniform1i glGetUniformLocation(@program, "in_WindowHeight"), $window.height
      end
    end

    # Creates a copy of the shader program, recompiling the source,
    # but not preserving the uniform values.
    def dup
      self.class.new :vertex => @vertex_source, :fragment => @fragment_source
    end

    # Make this the current shader program.
    def use
      previous_program = glGetIntegerv GL_CURRENT_PROGRAM
      glUseProgram @program

      if block_given?
        result = yield self
        $window.flush # TODO: need to work out how to make shader affect delayed draws.
        glUseProgram previous_program
      end

      result
    end

    # Disable the shader program (not needed in block version of #use).
    def disable
      glUseProgram 0 # Disable the shader!
    end

    # Is this the current shader program?
    def current?
      glGetIntegerv(GL_CURRENT_PROGRAM) == @program
    end

    # Allow
    #   `shader.blob_frequency = 5`
    # to map to
    #   `shader[:in_BlobFrequency] = 5`
    # TODO: define specific methods at compile time, based on parsing the source?
    def method_missing(meth, *args, &block)
      if args.size == 1 and meth =~ /^(.+)=$/
        uniform_name = "in_#{$1.split("_").map(&:capitalize).join}"
        self[uniform_name] = args[0]
      else
        super meth, *args, &block
      end
    end

    # Set the value of a uniform.
    def []=(name, value)
      name = name.to_sym

      use do
        case value
          when true, GL_TRUE
            glUniform1i uniform(name), 1

          when false, GL_FALSE
            glUniform1i uniform(name), 0

          when Float
            glUniform1f uniform(name), value

          when Integer
            glUniform1i uniform(name), value

          when Gosu::Color
            glUniform4f uniform(name), *value.to_opengl

          when Array
            size = value.size

            raise ArgumentError, "Empty array not supported for uniform data" if size.zero?
            raise ArgumentError, "Only support uniforms up to 4 elements" if size > 4

            case value[0]
              when Float
                GL.send "glUniform#{size}f", uniform(name), *value

              when Integer
                GL.send "glUniform#{size}i", uniform(name), *value

              else
                raise ArgumentError, "Uniform data type not supported for element of type: #{value[0].class}"
            end

          else
            raise ArgumentError, "Uniform data type not supported for type: #{value.class}"
        end
      end
    end



    def uniform(name)
      location = @uniform_locations[name]
      if location
        location
      else
        location = glGetUniformLocation @program, name.to_s
        raise ShaderUniformError, "No #{name} uniform specified in program" if location == INVALID_LOCATION
        @uniform_locations[name] = location
      end
    end



    def image=(image)
      use do
        if image
          info = image.gl_tex_info

          # Bind the single texture to 'in_Texture'
          glActiveTexture GL_TEXTURE0
          glBindTexture GL_TEXTURE_2D, info.tex_name
          self[:in_Texture] = 0
          raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE0
        end
      end

      glUniform1i glGetAttribLocation(@program, "in_TextureEnabled"), image ? 1 : 0

      @image = image
    end

    def color=(color)
      raise unless current?

      opengl_color = color.is_a?(Gosu::Color) ? color.to_opengl : color

      #glVertexAttrib4f glGetAttribLocation(@program, "in_Color"), *opengl_color
      @color = opengl_color
    end

    protected
    def attribute(name)
      location = @attribute_locations[name]
      if location
        location
      else
        location = glGetAttribLocation @program, name.to_s
        raise ShaderAttributeError, "No #{name} attribute specified in program" if location == INVALID_LOCATION
        @attribute_locations[name] = location
      end
    end

    protected
    def compile(type, source)
      shader = glCreateShader type
      glShaderSource shader, source
      glCompileShader shader

      unless glGetShaderiv shader, GL_COMPILE_STATUS
        error = glGetShaderInfoLog shader
        error_lines = error.scan(/0\((\d+)\)+/m).map {|num| num.first.to_i }.uniq

        if type == GL_VERTEX_SHADER
          type_name =  "Vertex"
          source = @vertex_source
        else
          type_name = "Fragment"
          source = @fragment_source
        end

        source_lines = source.split("\n")
        lines = error_lines.map {|i| "#{i.to_s.rjust 3}: #{source_lines[i - 1].rstrip}" }.join "\n"
        raise ShaderCompileError, "#{type_name} shader error: #{glGetShaderInfoLog(shader)}\n#{lines}"
      end

      shader
    end

    protected
    def link
      @program = glCreateProgram
      glAttachShader @program, @vertex
      glAttachShader @program, @fragment
      glLinkProgram @program

      unless glGetProgramiv @program, GL_LINK_STATUS
        raise ShaderLinkError, "Shader link error: #{glGetProgramInfoLog(@program)}"
      end

      nil
    end

    protected
    # Symbol => load a built-in
    # Filename => load file
    # Source => use directly.
    #
    # Also recursively replaces #include
    # TODO: What about line numbers getting messed up by #include?
    def process_source(shader, extension)
      source = if shader.is_a? Symbol
                 File.read File.expand_path("#{shader}#{extension}", SHADER_PATH)
               elsif File.exists? shader
                 File.read shader
               else
                 shader
               end

      replace_include source
    end

    protected
    # Recursively replace #include.
    #
    # * Replace '#include <rand>' with the contents of include/rand.glsl
    # * Replace '#include "/home/spooner/my_shader_functions/frog.glsl"' with the contents of that file.
    #
    # @return [String] Source code that has been expanded.
    def replace_include(source)
      source.gsub! /^#include\s+<(.+)?>\s+$/ do
        replace_include File.read(File.expand_path("#{$1}.glsl", INCLUDE_PATH))
      end

      source.gsub /^#include\s+"(\w+)"\s+$/ do
        replace_include File.read($1)
      end
    end
  end
end