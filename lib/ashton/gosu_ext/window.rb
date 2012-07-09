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

    # TODO: accept multiple shaders.
    def post_process(shader)
      raise ArgumentError, "Block required" unless block_given?

      Window.back_buffer ||= Ashton::Framebuffer.new width, height

      buffer = Window.back_buffer
      buffer.clear

      # allow drawing into the back-buffer.
      buffer.use do
        yield
      end

      # Draw the back-buffer onto the window, utilising the shader.
      shader.use do
        shader["in_Texture"] = 0
        buffer.draw 0, 0
      end
    end
  end
end