module Ashton
  class Shader
    INVALID_LOCATION = -1
    BOOL_TRUE, BOOL_FALSE = 1, 0

    attr_reader :image

    class << self
      # Canvas used to copy out the screen before post-processing it back onto the screen.
      def canvas_texture
        @canvas_texture ||= begin
          texture = glGenTextures(1).first
          glBindTexture GL_TEXTURE_2D, texture
          glTexParameteri GL_TEXTURE_2D, GL_GENERATE_MIPMAP, 1
          glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
          glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
          glTexImage2D GL_TEXTURE_2D, 0, GL_RGB8, $window.width, $window.height, 0,
                       GL_RGB, GL_UNSIGNED_BYTE, nil
          texture
        end
      end
    end

    def initialize(options = {})
      @uniform_locations = {}
      @attribute_locations = {}
      @image = nil

      @vertex_source = options[:vertex] || DEFAULT_VERTEX_SOURCE
      @fragment_source = options[:fragment] || options[:frag] || DEFAULT_FRAGMENT_SOURCE

      @vertex = compile GL_VERTEX_SHADER, @vertex_source
      @fragment = compile GL_FRAGMENT_SHADER, @fragment_source

      link

      self.color = [1, 1, 1, 1]
    end

    # Make this the current shader program.
    def use
      previous_program = glGetIntegerv GL_CURRENT_PROGRAM
      glUseProgram @program

      if block_given?
        result = yield self
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

    def image=(image)
      use do
        if image
          info = image.gl_tex_info

          # Bind the single texture to 'in_Texture'
          glActiveTexture GL_TEXTURE0
          glBindTexture GL_TEXTURE_2D, info.tex_name
          glUniform1i uniform("in_Texture"), 0
          raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE0

          # Ensure that the shader knows to use the texture.
          glUniform1i uniform("in_TextureEnabled"), BOOL_TRUE

          glUniform2f uniform("in_SpriteOffset"), info.left, info.top
          glUniform2f uniform("in_SpriteSize"), info.right - info.left, info.bottom - info.top
        else
          glUniform1i uniform("in_TextureEnabled"), BOOL_FALSE
        end
      end

      @image = image
    end

    def color=(color)
      #use do
        glVertexAttrib4f attribute("in_Color"), *color
      #end
      @color = color
    end

    # Set the value of a uniform.
    def []=(name, value)
      use do
        case value
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
                GL.send "glUniform#{size}f", uniform(name), value

              when Integer
                GL.send "glUniform#{size}i", uniform(name), value

              else
                raise ArgumentError, "Uniform data type not supported for element of type: #{value[0].class}"
            end

          else
            raise ArgumentError, "Uniform data type not supported for type: #{value.class}"
        end
      end
    end

    # Full screen post-processing using the shader.
    def post_process
      $window.gl do
        width, height = $window.width, $window.height
        canvas = Shader.canvas_texture

        # copy frame buffer to canvas texture
        glBindTexture GL_TEXTURE_2D, canvas
        glCopyTexImage2D GL_TEXTURE_2D, 0, GL_RGBA8, 0, 0, width, height, 0

        use do
          # clear screen
          glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
          glColor4f 1.0, 1.0, 1.0, 1.0
          glMatrixMode GL_PROJECTION
          glLoadIdentity
          glViewport 0, 0, width, height
          glOrtho 0, width, height, 0, -1, 1

          # Assign the canvas, which was a copy of the screen.
          glActiveTexture GL_TEXTURE0
          glBindTexture GL_TEXTURE_2D, canvas
          glUniform1i uniform("in_Texture"), 0
          raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE0

          glUniform1i uniform("in_TextureEnabled"), BOOL_TRUE
          glUniform2f uniform("in_SpriteOffset"), 0, 0
          glUniform2f uniform("in_SpriteSize"), width, height

          # draw processed canvas texture over the screen
          glBindTexture GL_TEXTURE_2D, canvas

          glBegin GL_QUADS do
            glTexCoord2f(0.0, 1.0); glVertex2f(0.0,   0.0)
            glTexCoord2f(1.0, 1.0); glVertex2f(width, 0.0)
            glTexCoord2f(1.0, 0.0); glVertex2f(width, height)
            glTexCoord2f(0.0, 0.0); glVertex2f(0.0,   height)
          end
        end
      end
    end

    protected
    def uniform(name)
      location = @uniform_locations[name]
      if location
        location
      else
        location = glGetUniformLocation @program, name.to_s
        raise "No #{name} uniform specified in program" if location == INVALID_LOCATION
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
        raise "No #{name} attribute specified in program" if location == INVALID_LOCATION
        @attribute_locations[name] = location
      end
    end

    protected
    def compile(type, source)
      shader = glCreateShader type
      glShaderSource shader, source
      glCompileShader shader

      unless glGetShaderiv shader, GL_COMPILE_STATUS
        raise glGetShaderInfoLog(shader)
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
        raise glGetProgramInfoLog(@program)
      end

      nil
    end

    DEFAULT_VERTEX_SOURCE =<<END
#version 110

uniform mat4 in_ModelView;
uniform mat4 in_ProjectionView;

attribute vec4 in_Vertex;
attribute vec2 in_TexCoord;

attribute vec4 in_Color;

uniform vec2 in_SpriteOffset;
uniform vec2 in_SpriteSize;

varying vec4 var_Color;
varying vec2 var_TexCoord; 

void main()
{
  //gl_Position = in_Vertex * gl_ProjectionMatrix;// * in_ModelView * in_ProjectionView;
  //gl_Position = vec4(in_Vertex, 0.0, 1.0)* (in_ModelView * in_Projection);
  //gl_Position = in_Vertex;
  gl_Position = ftransform();
  var_Color = in_Color;
  var_TexCoord = in_SpriteOffset + (in_TexCoord * in_SpriteSize);
}
END

    DEFAULT_FRAGMENT_SOURCE =<<END
#version 110

uniform sampler2D in_Texture;
uniform bool in_TextureEnabled;

varying vec4 var_Color;
varying vec2 var_TexCoord;

void main()
{   if(in_TextureEnabled)
  {
    gl_FragColor = texture2D(in_Texture, var_TexCoord) * var_Color;
  }
  else
  {
    gl_FragColor = var_Color;
  }
}
END
  end
end