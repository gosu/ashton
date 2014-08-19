module Ashton
  # A texture that is the same size as the Gosu::Window.
  class WindowBuffer < Texture
    def initialize
      super $window.width, $window.height
    end

    public
    # Copy the window contents into the buffer.
    def capture
      Gl.glBindTexture Gl::GL_TEXTURE_2D, id
      Gl.glCopyTexImage2D Gl::GL_TEXTURE_2D, 0, Gl::GL_RGBA8, 0, 0, width, height, 0
      self
    end
  end
end