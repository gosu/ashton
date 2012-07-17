# Set the window global, in case it hasn't been set (e.g. by Chingu)
module Gosu
  class Window
    class << self
      WHITE_PIXEL_BLOB = "\xFF" * 4

      # Used for post-processing effects, but could be used by any
      # anyone needing to have a temporary, full-window render buffer.
      def back_buffer
        @back_buffer ||= Ashton::WindowBuffer.new
      end

      def pixel
        @pixel ||= Gosu::Image.new $window, Ashton::ImageStub.new(WHITE_PIXEL_BLOB, 1, 1)
      end
    end

    def pixel; Window.pixel; end

    alias_method :ashton_initialize, :initialize
    def initialize(*args, &block)
      $window = self
      ashton_initialize *args, &block
    end

    alias_method :gl_not_liking_nil, :gl
    protected :gl_not_liking_nil
    def gl(z = nil, &block)
      if z
        gl_not_liking_nil z, &block
      else
        gl_not_liking_nil &block
      end
    end

    # Full screen post-processing using a fragment shader.
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

      buffer = Window.back_buffer
      buffer.clear

      # allow drawing into the back-buffer.
      buffer.render do
        yield
      end

      $window.gl do
        # Clear screen and set "normal" Gosu coordinates.
        glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
        glColor4f 1.0, 1.0, 1.0, 1.0
        glMatrixMode GL_PROJECTION
        glLoadIdentity
        glViewport 0, 0, width, height
        glOrtho 0, width, height, 0, -1, 1

        # Draw the back-buffer onto the window, utilising the shader.
        buffer.draw 0, 0, nil, shader: shaders[0]

        # If using additional shaders, copy the screen out to the buffer and shader it.
        # This is slower, but saves having a second back-buffer.
        shaders[1..-1].each do |shader|
          buffer.capture
          buffer.draw 0, 0, nil, shader: shader
        end
      end
    end
  end
end