# Set the window global, in case it hasn't been set (e.g. by Chingu)
module Gosu
  class Window
    class << self
      # Used for post-processing effects.
      attr_accessor :back_buffer
    end

    alias_method :ashton_initialize, :initialize
    def initialize(*args, &block)
      $window = self
      ashton_initialize *args, &block
    end

    # Full screen post-processing using a fragment shader.
    #
    # It will force all previous draw operations to be flushed to the
    # screen, so that you can, or example, process the "game world" before you draw the GUI.
    #
    # Variables set for you in the fragment shader:
    #   uniform sampler2D in_Texture; // Texture containing the screen image.
    def post_process(*shaders)
      raise ArgumentError, "Block required" unless block_given?
      raise TypeError, "Can only process with Shaders" unless shaders.all? {|s| s.is_a? Ashton::Shader }

      # In case no shaders are passed, just run the contents of the block.
      unless shaders.size > 0
        yield
        return
      end

      Window.back_buffer ||= Ashton::Framebuffer.new width, height

      buffer = Window.back_buffer
      buffer.clear

      # allow drawing into the back-buffer.
      buffer.use do
        yield
      end

      $window.gl do
        # clear screen and set "normal" openGL coordinates.
        glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
        glColor4f 1.0, 1.0, 1.0, 1.0
        glMatrixMode GL_PROJECTION
        glLoadIdentity
        glViewport 0, 0, width, height
        glOrtho 0, width, height, 0, -1, 1

        # Assign the canvas, which was a copy of the screen.
        glActiveTexture GL_TEXTURE0
        glBindTexture GL_TEXTURE_2D, buffer.texture
        raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE0

        # Draw the back-buffer onto the window, utilising the shader.
        shaders[0].use do |shader|
          shader["in_Texture"] = 0
          buffer.draw 0, 0
        end

        # If using additional shaders, copy the screen out to the buffer and shader it.
        shaders[1..-1].each do |shader|
          # Copy window contents into a frame-buffer.
          glBindTexture GL_TEXTURE_2D, buffer.texture
          glCopyTexImage2D GL_TEXTURE_2D, 0, GL_RGBA8, 0, 0, width, height, 0

          shader["in_Texture"] = 0
          shader.use do
            buffer.draw 0, 0
          end
        end
      end
    end
  end
end