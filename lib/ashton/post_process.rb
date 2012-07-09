require "ashton/base_shader"

module Ashton
  # Process the entire screen.
  class PostProcess < BaseShader
    DEFAULT_VERTEX_SOURCE = File.read File.expand_path("../post_process/default.vert", __FILE__)

    class << self
      # Canvas used to copy out the screen before post-processing it back onto the screen.
      # We only need one of these, but only create it after a PostProcessor has
      # actually been used.
      def texture
        @texture ||= begin
          texture = glGenTextures(1).first
          glBindTexture GL_TEXTURE_2D, texture
          glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR
          glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR
          glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
          glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
          glTexImage2D GL_TEXTURE_2D, 0, GL_RGB8, $window.width, $window.height, 0,
                       GL_RGB, GL_UNSIGNED_BYTE, "\0" * ($window.width * $window.height * 3)
          texture
        end
      end
    end

    # Todo: Pass in a filename (String) or name of built-in pp shader (Symbol)
    def initialize(fragment)
      super DEFAULT_VERTEX_SOURCE, fragment

      # Set up defaults that we won't need to change at run-time.
      use do
        self["in_WindowWidth"], self["in_WindowHeight"] = $window.width, $window.height
        self["in_Texture"] = 0 # GL_TEXTURE0 will be activated.
      end
    end

    # Full screen post-processing using a fragment shader.
    #
    # It will force all previous draw operations to be flushed to the
    # screen, so that you can, or example, process the "game world" before you draw the GUI.
    #
    # Variables set for you in the fragment shader:
    #   uniform sampler2D in_Texture; // Texture containing the screen image.
    #   uniform int in_WindowWidth;
    #   uniform int in_WindowHeight;
    def process
      $window.gl do
        width, height = $window.width, $window.height
        texture = PostProcess.texture

        # Copy window contents into a frame-buffer.
        glBindTexture GL_TEXTURE_2D, texture
        glCopyTexImage2D GL_TEXTURE_2D, 0, GL_RGBA8, 0, 0, width, height, 0

        # clear screen and set "normal" openGL coordinates.
        glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
        glColor4f 1.0, 1.0, 1.0, 1.0
        glMatrixMode GL_PROJECTION
        glLoadIdentity
        glViewport 0, 0, width, height
        glOrtho 0, width, height, 0, -1, 1

        # Assign the canvas, which was a copy of the screen.
        glActiveTexture GL_TEXTURE0
        glBindTexture GL_TEXTURE_2D, texture
        raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE0

        use do
          glBegin GL_QUADS do
            glTexCoord2f(0.0, 1.0); glVertex2f(0.0,   0.0)
            glTexCoord2f(1.0, 1.0); glVertex2f(width, 0.0)
            glTexCoord2f(1.0, 0.0); glVertex2f(width, height)
            glTexCoord2f(0.0, 0.0); glVertex2f(0.0,   height)
          end
        end
      end
    end
  end
end