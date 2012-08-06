module Ashton
  class ParticleEmitter
    def empty?; count == 0 end

    DEFAULT_MAX_PARTICLES = 1000
    DEFAULT_COLOR = Gosu::Color::WHITE
    RANGED_ATTRIBUTES = [
        :angular_velocity, :center_x, :center_y,
        :fade, :friction, :interval,
        :offset, :scale, :speed, :time_to_live, :zoom
    ]

    def initialize(x, y, z, options = {})
      # I'm MUCH too lazy to implement a huge options hash manager in C, especially on a constructor.
      max_particles = options[:max_particles] || DEFAULT_MAX_PARTICLES
      initialize_ x, y, z, max_particles

      self.shader = options[:shader]
      self.image = options[:image] || $window.pixel

      self.gravity = options[:gravity] || 0.0
      self.color = options[:color] || DEFAULT_COLOR

      self.angular_velocity = options[:angular_velocity] || 0.0
      self.center_x = options[:center_x] || 0.5
      self.center_y = options[:center_y] || 0.5
      self.fade = options[:fade] || 0.0
      self.friction = options[:friction] || 0.0
      self.interval = options[:interval] || Float::INFINITY
      self.offset = options[:offset] || 0.0
      self.scale = options[:scale] || 1.0
      self.speed = options[:speed] || 0.0
      self.time_to_live = options[:time_to_live] || Float::INFINITY
      self.zoom = options[:zoom] || 0.0
    end

    # Gosu::Color
    def color
      Gosu::Color.new color_argb
    end

    # [Gosu::Color, Integer, Array<Float>]
    def color=(value)
      case value
        when Integer
          self.color_argb = value
        when Gosu::Color
          self.color_argb = value.to_i
        when Array
          self.color_argb = Gosu::Color.from_opengl value
        else
          raise TypeError, "Expected argb integer, rgba opengl float array or Gosu::Color"
      end

      value
    end

    RANGED_ATTRIBUTES.each do |attr|
      # Returns a Range.
      define_method attr do
        send("#{attr}_min")..send("#{attr}_max")
      end

      # Can be set as a Range or as a single number.
      define_method "#{attr}=" do |value|
        min, max = case value
                     when Numeric
                       [value, value]
                     when Range
                       [value.min, value.max]
                     else
                       raise TypeError, "Expecting Numeric or Range, not #{value.class}"
                   end

        send "#{attr}_min=", min
        send "#{attr}_max=", max

        value
      end
    end

    # @!method draw()

    # @!method update(delta)
    #   @param delta (Float) number of seconds to run the simulation for.
  end
end