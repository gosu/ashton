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
      options = {
          center_x: 0.5,
          center_y: 0.5,
          image: $window.pixel,
          color: DEFAULT_COLOR,
          max_particles: DEFAULT_MAX_PARTICLES,
          gravity: 0.0,
          angular_velocity: 0.0,
          fade: 0.0,
          friction: 0.0,
          interval: 1_000_000_000, #Float::INFINITY, # BUG: INFINITY => NaN in C
          offset: 0.0,
          scale: 1.0,
          speed: 0.0,
          time_to_live: 1_000_000_000, #Float::INFINITY,  # BUG: INFINITY => NaN in C
          zoom: 0.0,
      }.merge! options
      
      @image = options[:image] || $window.pixel

      @shader = options[:shader]

      initialize_ x, y, z, options[:max_particles]

      self.gravity = options[:gravity]
      self.color = options[:color]

      self.angular_velocity = options[:angular_velocity]
      self.center_x = options[:center_x]
      self.center_y = options[:center_y]
      self.fade = options[:fade]
      self.friction = options[:friction]
      self.interval = options[:interval]
      self.offset = options[:offset]
      self.scale = options[:scale]
      self.speed = options[:speed]
      self.time_to_live = options[:time_to_live]
      self.zoom = options[:zoom]
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
                       raise TypeError
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