module Ashton
  class Shader
    INVALID_LOCATION = -1
    MIN_OPENGL_VERSION = 2.0

    attr_reader :image

    INCLUDE_PATH = File.expand_path "../shaders/include", __FILE__
    SHADER_PATH = File.expand_path "../shaders", __FILE__
    DEFAULT_VERTEX_SOURCE = File.read File.join(SHADER_PATH, "default.vert")
    DEFAULT_FRAGMENT_SOURCE = File.read File.join(SHADER_PATH, "default.frag")

    # Todo: Pass in a filename (String) or name of built-in pp shader (Symbol)
    #
    # @option options [String] :vertex Source code for vertex shader.
    # @option options [String] :vert equivalent to :vertex
    # @option options [String] :fragment Source code for fragment shader.
    # @option options [String] :frag equivalent to :fragment
    def initialize(options = {})
      unless GL.version_supported? MIN_OPENGL_VERSION
        raise NotSupportedError, "Ashton requires OpenGL #{MIN_OPENGL_VERSION} support to utilise shaders"
      end

      vertex_source = options[:vertex] || options[:vert] || DEFAULT_VERTEX_SOURCE
      fragment_source = options[:fragment] || options[:frag] || DEFAULT_FRAGMENT_SOURCE

      @uniform_locations = {}
      @attribute_locations = {}
      @program = nil
      @image = nil
      @color = [1, 1, 1, 1]

      @vertex_source = vertex_source
      @fragment_source = fragment_source

      # Actually compile and link.
      @vertex = compile GL_VERTEX_SHADER, vertex_source
      @fragment = compile GL_FRAGMENT_SHADER, fragment_source
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

    # Set the value of a uniform.
    def []=(name, value)
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
          self["in_Texture"] = 0
          raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE0

          # Ensure that the shader knows to use the texture.
          self["in_TextureEnabled"] = true
        else
          begin
            self["in_TextureEnabled"] = false
          rescue
          end
        end
      end

      @image = image
    end

    def color=(color)
      raise unless current?

      opengl_color = color.is_a?(Gosu::Color) ? color.to_opengl : color

      glVertexAttrib4f attribute("in_Color"), *opengl_color
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
  end
end