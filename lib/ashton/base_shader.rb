module Ashton
  # @abstract
  class BaseShader
    INVALID_LOCATION = -1
    MIN_OPENGL_VERSION = 2.0

    attr_reader :fragment_source, :vertex_source

    # Todo: Pass in a filename (String) or name of built-in pp shader (Symbol)
    #
    # @option options [String] :vertex Source code for vertex shader.
    # @option options [String] :vert equivalent to :vertex
    # @option options [String] :fragment Source code for fragment shader.
    # @option options [String] :frag equivalent to :fragment
    def initialize(vertex_source, fragment_source)
      raise "Can't instantiate abstract class" if self.class == BaseShader

      unless GL.version_supported? MIN_OPENGL_VERSION
        raise NotSupportedError, "Ashton requires OpenGL #{MIN_OPENGL_VERSION} support to utilise shaders"
      end

      @uniform_locations = {}
      @attribute_locations = {}
      @program = nil

      @vertex_source = vertex_source
      @fragment_source = fragment_source

      @vertex = compile GL_VERTEX_SHADER, vertex_source
      @fragment = compile GL_FRAGMENT_SHADER, fragment_source

      link

      glBindFragDataLocationEXT @program, 0, "out_FragColor"
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