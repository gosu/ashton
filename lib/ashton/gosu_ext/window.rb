# Set the window global, in case it hasn't been set (e.g. by Chingu)
module Gosu
  class Window
    class << self
      WHITE_PIXEL_BLOB = "\xFF" * 4

      # Used for post-processing effects, but could be used by
      # anyone needing to have a temporary, full-window render buffer.
      def primary_buffer; @primary_buffer ||= Ashton::WindowBuffer.new end

      # Used for post-processing effects, but could be used by
      # anyone needing to have a temporary, full-window render buffer.
      def secondary_buffer; @secondary_buffer ||= Ashton::WindowBuffer.new end

      # An image containing a single white pixel. Useful for drawing effects (rectangle, lines, etc).
      def pixel
        @pixel ||= Gosu::Image.new $window, Ashton::ImageStub.new(WHITE_PIXEL_BLOB, 1, 1), true
      end
    end

    def pixel; Window.pixel end
    def primary_buffer; Window.primary_buffer end
    def secondary_buffer; Window.secondary_buffer end

    alias_method :ashton_initialize, :initialize
    def initialize(*args, &block)
      $window = self
      ashton_initialize(*args, &block)
    end

    alias_method :gl_not_liking_nil, :gl
    protected :gl_not_liking_nil
    def gl(z = nil, &block)
      if z
        gl_not_liking_nil(z, &block)
      else
        gl_not_liking_nil(&block)
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

      buffer1 = primary_buffer
      buffer1.clear

      # Allow user to draw into a buffer, rather than the window.
      buffer1.render do
        yield
      end

      if shaders.size > 1
        buffer2 = secondary_buffer # Don't need to clear, since we will :replace.

        # Draw into alternating buffers, applying each shader in turn.
        shaders[0...-1].each do |shader|
          buffer1, buffer2 = buffer2, buffer1
          buffer1.render do
            buffer2.draw 0, 0, nil, shader: shader, mode: :replace
          end
        end
      end

      # Draw the buffer directly onto the window, utilising the (last) shader.
      buffer1.draw 0, 0, nil, shader: shaders.last
    end
  end
end