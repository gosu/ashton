module Ashton
  class SignedDistanceField
    ZERO_DISTANCE = 128 # color channel containing 0 => -128, 128 => 0, 255 => +127

    # Creates a Signed Distance Field based on a given image.
    # Image should be a mask with alpha = 0 (clear) and alpha = 255 (solid)
    #
    # @param image [Gosu::Image, Ashton::Framebuffer]
    # @param max_distance [Integer] Maximum distance to measure.
    # @option options :step_size [Integer] (1) pixels to step out.
    # @option options :scale [Integer] (1) Scale relative to the image.
    def initialize(image, max_distance, options = {})
      options = {
         scale: 1,
         step_size: 1,
      }.merge! options

      @image = image
      @scale = options[:scale].to_f

      @shader = Shader.new fragment: :signed_distance_field, uniforms: {
          max_distance: max_distance.ceil,
          step_size: options[:step_size].floor, # One pixel.
          texture_size: [image.width, image.height].map(&:to_f),
      }

      @field = Framebuffer.new (image.width / @scale).ceil, (image.height / @scale).ceil

      update_field
    end

    # Is the position clear for a given radius around it.
    def position_clear?(x, y, radius)
      clear_distance(x, y) >= radius
    end

    # If positive, distance, in pixels, to the nearest opaque pixel.
    # If negative, distance in pixels to the nearest transparent pixel.
    def clear_distance(x, y)
      # Could be checking any of red/blue/green.
      @field.red(x / @scale, y / @scale) - ZERO_DISTANCE
    end

    # Update the SDF should the image have changed.
    def update_field
      @shader.use do
        @field.render do
          $window.scale 1.0 / @scale do
            @image.draw 0, 0, 0
          end
        end
      end

      nil
    end

    # Draw the field, usually for debugging purposes.
    # @see Ashton::Framebuffer#draw
    def draw(x, y, z, options = {})
      options = {
          blend: :add,
      }.merge! options

      $window.scale @scale do
        @field.draw x, y, z, options
      end

      nil
    end
  end
end