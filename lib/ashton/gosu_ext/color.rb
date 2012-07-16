module Gosu
  class Color
    # @!method self.from_opengl(rgba_array)
    #   Convert into an array of floats in range 0.0 to 1.0.
    #
    #   @param rgba_array [Array<Float>]
    #   @return [Gosu::Color]


    # @!method to_opengl
    #   Convert into a length 4 array of floats in range 0.0 to 1.0, which
    #   can then be passed into OpenGL ruby methods.
    #
    #   @example
    #     color = Gosu::Color.rgba 128, 0, 0, 255 # => [0.502, 0.0, 0.0, 1.0]
    #     glColor4f *color.to_opengl
    #
    #   @return [Array<Float>]


    # @!method to_i
    #   Convert to Gosu-compatible ARGB value (0xAARRGGBB)
    #   @return [Integer]
  end
end