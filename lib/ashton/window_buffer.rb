module Ashton
  # A framebuffer that is the same size as the Gosu::Window.
  class WindowBuffer < Framebuffer
    def initialize
      super $window.width, $window.height
    end

    public
    # Copy the window contents into the buffer.
    def capture
      glBindTexture GL_TEXTURE_2D, @texture
      glCopyTexImage2D GL_TEXTURE_2D, 0, GL_RGBA8, 0, 0, width, height, 0
    end
  end
end