module Ashton
  class Shader
    include Mixins::VersionChecking

    INVALID_LOCATION = -1
    MIN_OPENGL_VERSION = 2.0 # For GLSL 1.10

    INCLUDE_PATH = File.expand_path "../shaders/include", __FILE__
    BUILT_IN_SHADER_PATH = File.expand_path "../shaders", __FILE__
    FRAGMENT_EXTENSION = ".frag"
    VERTEX_EXTENSION = ".vert"

    # List of built-in functions.
    BUILT_IN_FUNCTIONS = Dir[File.join(INCLUDE_PATH, "*.glsl")].map do |filename|
      filename =~ /(\w+)\.glsl/
      $1.to_sym
    end

    attr_reader :vertex_source, :fragment_source

    # Is the shader currently in use?
    def enabled?; !!@previous_program end

    # Is this the currently activated shader program?
    def current?; Gl.glGetIntegerv(Gl::GL_CURRENT_PROGRAM) == @program end

    # Instead of passing in source code, a file-name will be loaded or use a symbol to choose a built-in shader.
    #
    # `#include` will be recursively replaced in the source.
    #
    # * `#include <noise>` will load the built-in shader function, shaders/include/noise.glsl
    # * `#include "/home/spooner/noise.glsl"` will include that file, relative to the current working directory, NOT the source file.
    #
    # @option options :vertex [String, Symbol] (:default) Source code for vertex shader.
    # @option options :vert [String, Symbol] (:default) Equivalent to :vertex
    # @option options :fragment [String, Symbol] (:default) Source code for fragment shader.
    # @option options :frag [String, Symbol] (:default) Equivalent to :fragment
    # @option options :uniforms [Hash] Sets uniforms, as though calling shader[key] = value for each entry (but faster).
    def initialize(options = {})
      check_opengl_version MIN_OPENGL_VERSION

      vertex = options[:vertex] || options[:vert] || :default
      fragment = options[:fragment] || options[:frag] || :default

      @vertex_source = process_source vertex, VERTEX_EXTENSION
      @fragment_source = process_source fragment, FRAGMENT_EXTENSION

      @uniform_locations = {}
      @attribute_locations = {}
      @program = nil
      @previous_program = nil
      @image = nil
      @color = [1, 1, 1, 1]

      # Actually compile and link.

      @vertex = compile Gl::GL_VERTEX_SHADER, @vertex_source
      @fragment = compile Gl::GL_FRAGMENT_SHADER, @fragment_source
      link

      # In case we are using '#version 130' or higher, set out own color output.
      begin
        Gl.glBindFragDataLocationEXT @program, 0, "out_FragColor"
      rescue NotImplementedError
        # Might fail on an old system, but they will be fine just running GLSL 1.10 or 1.20
      end

      enable do
        # GL_TEXTURE0 will be activated later. This is the main image texture.
        set_uniform uniform_location("in_Texture", required: false), 0

        # For multi-textured shaders, we use in_Texture<NUM> instead.
        set_uniform uniform_location("in_Texture0", required: false), 0
        set_uniform uniform_location("in_Texture1", required: false), 1

        # These are optional, and can be used to check pixel size.
        set_uniform uniform_location("in_WindowWidth", required: false), $window.width
        set_uniform uniform_location("in_WindowHeight", required: false), $window.height

        # Set uniform values with :uniforms hash.
        if options.has_key? :uniforms
          options[:uniforms].each_pair do |uniform, value|
            self[uniform] = value
          end
        end
      end
    end

    protected
    # Converts :frog_head to "in_FrogHead"
    def uniform_name_from_symbol(uniform)
      "in_#{uniform.to_s.split("_").map(&:capitalize).join}"
    end

    public
    # Creates a copy of the shader program, recompiling the source,
    # but not preserving the uniform values.
    def dup
      self.class.new :vertex => @vertex_source, :fragment => @fragment_source
    end

    public
    # Make this the current shader program. Use with a block or, alternatively, use #enable and #disable separately.
    def enable(z = nil)
      $window.gl z do
        raise ShaderError, "This shader already enabled." if enabled?
        current_shader = Gl.glGetIntegerv GL::GL_CURRENT_PROGRAM
        raise ShaderError, "Another shader already enabled." if current_shader > 0

        @previous_program = current_shader
        Gl.glUseProgram @program
      end

      result = nil

      if block_given?
        begin
          result = yield self
        ensure
          disable z
        end
      end

      result
    end

    # Disable the shader program. Only required if using #enable without a block.
    def disable(z = nil)
      $window.gl z do
        raise ShaderError, "Shader not enabled." unless enabled?
        Gl.glUseProgram @previous_program # Disable the shader!
        @previous_program = nil
      end

      nil
    end

    public
    # Allow
    #   `shader.blob_frequency = 5`
    # to map to
    #   `shader["in_BlobFrequency"] = 5`
    # TODO: define specific methods at compile time, based on parsing the source?
    def method_missing(meth, *args, &block)
      if args.size == 1 and meth =~ /^(.+)=$/
        self[$1.to_sym] = args[0]
      else
        super meth, *args, &block
      end
    end

    public
    # Set the value of a uniform.
    #
    # @param uniform [String, Symbol] If a Symbol, :frog_paste is looked up as "in_FrogPaste", otherwise the Sting is used directly.
    # @param value [Any] Value to set the uniform to
    #
    # @raise ShaderUniformError unless requested uniform is defined in vertex or fragment shaders.
    def []=(uniform, value)
      uniform = uniform_name_from_symbol(uniform) if uniform.is_a? Symbol

      # Ensure that the program is current before setting values.
      needs_use = !current?
      enable if needs_use
      set_uniform uniform_location(uniform), value
      disable if needs_use

      value
    end

    protected
    # Set uniform without trying to force use of the program.
    def set_uniform(location, value)
      raise ShaderUniformError, "Shader uniform #{location.inspect} could not be set, since shader is not current" unless current?

      return if location == INVALID_LOCATION # Not for end-users :)

      case value
        when true, Gl::GL_TRUE
          Gl.glUniform1i location, 1

        when false, Gl::GL_FALSE
          Gl.glUniform1i location, 0

        when Float
          begin
            Gl.glUniform1f location, value
          rescue
            Gl.glUniform1i location, value.to_i
          end

        when Integer
          begin
            Gl.glUniform1i location, value
          rescue
            Gl.glUniform1f location, value.to_f
          end

        when Gosu::Color
          Gl.glUniform4f location, *value.to_opengl

        when Array
          size = value.size

          raise ArgumentError, "Empty array not supported for uniform data" if size.zero?
          # raise ArgumentError, "Only support uniforms up to 4 elements" if size > 4

          case value[0]
            when Float
              begin
                Gl.send "glUniform#{size}f", location, *value.map(&:to_f)
              rescue
                Gl.send "glUniform#{size}i", location, *value.map(&:to_i)
              end

            when Integer
              begin
                Gl.send "glUniform#{size}i", location, *value.map(&:to_i)
              rescue
                Gl.send "glUniform#{size}f", location, *value.map(&:to_f)
              end

            when Gosu::Color
              GL.send "glUniform4fv", location, value.map(&:to_opengl).flatten

            else
              raise ArgumentError, "Uniform data type not supported for element of type: #{value[0].class}"
          end

        else
          raise ArgumentError, "Uniform data type not supported for type: #{value.class}"
      end

      value
    end

    protected
    def uniform_location(name, options = {})
      options = {
          required: true
      }.merge! options

      location = @uniform_locations[name]
      if location
        location
      else
        location = Gl.glGetUniformLocation @program, name.to_s
        if options[:required] && location == INVALID_LOCATION
          raise ShaderUniformError, "No #{name.inspect} uniform specified in program"
        end
        @uniform_locations[name] = location
      end
    end

    public
    def image=(image)
      raise ShaderError, "Can't set image unless using shader" unless current?

      if image
        info = image.gl_tex_info

        Gl.glActiveTexture Gl::GL_TEXTURE0
        Gl.glBindTexture Gl::GL_TEXTURE_2D, info.tex_name
      end

      set_uniform uniform_location("in_TextureEnabled", required: false), !!image

      @image = image
    end

    public
    def color=(color)
      opengl_color = case color
                       when Gosu::Color
                         color.to_opengl
                       when Integer
                         Gosu::Color.new(color).to_opengl
                       when Array
                         color
                       else
                         raise TypeError, "Expected Gosu::Color, Integer or opengl float array for color"
                     end

      needs_use = !current?
      enable if needs_use
      location = Gl.glGetAttribLocation @program, "in_Color"
      Gl.glVertexAttrib4f location, *opengl_color unless location == INVALID_LOCATION
      disable if needs_use

      @color = opengl_color
    end

    protected
    def attribute(name)
      location = @attribute_locations[name]
      if location
        location
      else
        location = Gl.glGetAttribLocation @program, name.to_s
        raise ShaderAttributeError, "No #{name} attribute specified in program" if location == INVALID_LOCATION
        @attribute_locations[name] = location
      end
    end

    protected
    def compile(type, source)
      shader = Gl.glCreateShader type
      Gl.glShaderSource shader, source
      Gl.glCompileShader shader

      unless Gl.glGetShaderiv shader, Gl::GL_COMPILE_STATUS
        error = Gl.glGetShaderInfoLog shader
        error_lines = error.scan(/0\((\d+)\)+/m).map {|num| num.first.to_i }.uniq

        if type == Gl::GL_VERTEX_SHADER
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
      @program = Gl.glCreateProgram
      Gl.glAttachShader @program, @vertex
      Gl.glAttachShader @program, @fragment
      Gl.glLinkProgram @program

      unless Gl.glGetProgramiv @program, Gl::GL_LINK_STATUS
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
                 file = File.expand_path "#{shader}#{extension}", BUILT_IN_SHADER_PATH
                 unless File.exist? file
                   raise ShaderLoadError, "Failed to load built-in shader: #{shader.inspect}"
                 end
                 File.read file

               elsif File.exist? shader
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
      source.gsub!(/^#include\s+<([^>]*)>/) do
        replace_include File.read(File.expand_path("#{$1}.glsl", INCLUDE_PATH))
      end

      source.gsub(/^#include\s+"([^"]*)"/) do
        replace_include File.read($1)
      end
    end
  end
end
