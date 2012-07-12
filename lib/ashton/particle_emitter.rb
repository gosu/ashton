module Ashton
  class ParticleEmitter
    def empty?; @points.empty? end
    def size; @points.size end

    WHITE_PIXEL_BLOB = "\xFF" * 4

    def initialize(x, y, z, options = {})
      @x, @y, @z = x, y, z

      @@pixel ||= Gosu::Image.new $window, Ashton::ImageStub.new(WHITE_PIXEL_BLOB, 1, 1)

      @speed = options[:speed] || 0
      @image = options[:image] || @@pixel
      @friction = options[:friction] || 0
      @color = options[:color] || Gosu::Color::WHITE

      @time_to_live = options[:time_to_live] || Float::INFINITY
      #@zoom = options[:zoom] || 1.0
      #@fade = options[:fade] || 1.0
      @gravity = options[:gravity] || 0
      @max_particles = options[:max_particles] || Float::INFINITY

      @scale = options[:scale] || 1.0
      @shader = options[:shader]
      @interval = options[:interval] || 1.0
      
      @speed_deviation = options[:speed_deviation] || 0
      @friction_deviation = options[:friction_deviation] || 0
      @time_to_live_deviation = options[:time_to_live_deviation] || 0
      @position_offset = options[:position_offset] || 0

      @points = []
      @data = []

      @time_until_emit = @interval
    end

    def update
      elapsed = 0.017

      destroyed = 0

      @data.each_with_index do |data|
        data[:time_to_live] -= elapsed

        if data[:time_to_live] <= 0
          destroyed += 1
        else
          # Physics motion.
          if data[:friction] != 0
            data[:velocity_x] *= 1 - (data[:friction] * elapsed)
            data[:velocity_y] *= 1 - (data[:friction] * elapsed)
          end

          data[:velocity_y] += @gravity * elapsed

          point = data[:point]
          point[0] += data[:velocity_x]
          point[1] += data[:velocity_y]

          #data[:scale] *= data[:zoom] * time
          #data[:alpha] *= data[:fade] * time
        end
      end

      @points.shift destroyed
      @data.shift destroyed

      if @points.size > @max_particles
        excess = @points.size - @max_particles
        @points.shift excess
        @data.shift excess
      end

      # Consider emitting one or more particles.
      @time_until_emit -= elapsed
      while @time_until_emit <= 0
        emit
        @time_until_emit += @interval
      end

      nil
    end

    def draw
      @image.draw_as_points @points, @z, scale: @scale,
                            shader: @shader, color: @color
    end

    def emit
      angle = rand() * 360

      speed = deviate @speed, @speed_deviation

      position_distance = deviate @position_offset / 2.0, 1.0
      position_angle = rand() * 360
      x = @x + Gosu::offset_x(position_angle, position_distance)
      y = @y + Gosu::offset_y(position_angle, position_distance)

      data = {
          friction:  deviate(@friction, @friction_deviation),
          velocity_x: Gosu::offset_x(angle, speed),
          velocity_y: Gosu::offset_y(angle, speed),
          time_to_live: deviate(@time_to_live, @time_to_live_deviation),
          point: [x, y],
      }

      @points << data[:point]
      @data << data

      nil
    end

    protected
    def deviate(value, deviation)
      value * (1 + rand() * deviation - rand() * deviation)
    end
  end
end