module Ashton
  class SignedDistanceField
    ZERO_DISTANCE = 128 # color channel containing 0 => -128, 128 => 0, 129 => +1, 255 => +128

    attr_reader :width, :height

    # Creates a Signed Distance Field based on a given image.
    # When drawing into the SDF, drawing should ONLY have alpha of 0 (clear) or 255 (solid)
    #
    # @param width [Integer]
    # @param height [Integer]
    # @param max_distance [Integer] Maximum distance to measure.
    # @option options :step_size [Integer] (1) pixels to step out.
    # @option options :scale [Integer] (1) Scale relative to the image.
    def initialize(width, height, max_distance, options = {}, &block)
      options = {
         scale: 1,
         step_size: 1,
      }.merge! options

      @width, @height = width, height
      @scale = options[:scale].to_f

      @shader = Shader.new fragment: :signed_distance_field, uniforms: {
          max_distance: max_distance.ceil,
          step_size: options[:step_size].floor, # One pixel.
          texture_size: [width, height].map(&:to_f),
      }

      @field = Texture.new (width / @scale).ceil, (height / @scale).ceil
      @mask = Texture.new @field.width, @field.height

      if block_given?
        render_field(&block)
      else
        @field.clear color: Gosu::Color.rgb(*([ZERO_DISTANCE + max_distance] * 3))
      end
    end

    # Is the position clear for a given radius around it.
    def position_clear?(x, y, radius)
      sample_distance(x, y) >= radius
    end

    # If positive, distance, in pixels, to the nearest opaque pixel.
    # If negative, distance in pixels to the nearest transparent pixel.
    def sample_distance(x, y)
      x = [[x, width - 1].min, 0].max
      y = [[y, height - 1].min, 0].max
      # Could be checking any of red/blue/green.
      @field.red((x / @scale).round, (y / @scale).round) - ZERO_DISTANCE
    end

    # Gets the gradient of the field at a given point.
    # @return [Float, Float] gradient_x, gradient_y
    def sample_gradient(x, y)
      d0 = sample_distance x, y - 1
      d1 = sample_distance x - 1, y
      d2 = sample_distance x + 1, y
      d3 = sample_distance x, y + 1

      [(d2 - d1) / @scale, (d3 - d0) / @scale]
    end

    # Get the normal at a given point.
    # @return [Float, Float] normal_x, normal_y
    def sample_normal(x, y)
      gradient_x, gradient_y = sample_gradient x, y
      length = Gosu::distance 0, 0, gradient_x, gradient_y
      if length == 0
        [0, 0] # This could be NaN in edge cases.
      else
        [gradient_x / length, gradient_y / length]
      end
    end

    # Does the point x1, x2 have line of sight to x2, y2 (that is, no solid in the way).
    def line_of_sight?(x1, y1, x2, y2)
      !line_of_sight_blocked_at(x1, y1, x2, y2)
    end

    # Returns blocking position, else nil if line of sight isn't blocked.
    def line_of_sight_blocked_at(x1, y1, x2, y2)
      distance_to_travel = Gosu::distance x1, y1, x2, y2
      distance_x, distance_y = x2 - x1, y2 - y1
      distance_travelled = 0
      x, y = x1, y1

      loop do
        distance = sample_distance x, y

        # Blocked?
        return [x, y] if distance <= 0

        distance_travelled += distance

        # Got to destination in the clear.
        return nil if distance_travelled >= distance_to_travel

        lerp = distance_travelled.fdiv distance_to_travel
        x = x1 + distance_x * lerp
        y = y1 + distance_y * lerp
      end
    end

    # Update the SDF should the image have changed.
    # Draw the mask in the passed block.
    def render_field
      raise ArgumentError, "Block required" unless block_given?

      @mask.render do
        @mask.clear
        $window.scale 1.0 / @scale do
          yield self
        end
      end

      @shader.enable do
        @field.render do
          @mask.draw 0, 0, 0
        end
      end

      nil
    end

    # Draw the field, usually for debugging purposes.
    # @see Ashton::Texture#draw
    def draw(x, y, z, options = {})
      options = {
          mode: :add,
      }.merge! options

      $window.scale @scale do
        @field.draw x, y, z, options
      end

      nil
    end

    # Convert into a nested array of sample values.
    # @return [Array<Array<Integer>>]
    def to_a
      width.times.map do |x|
        height.times.map do |y|
          sample_distance x, y
        end
      end
    end
  end
end