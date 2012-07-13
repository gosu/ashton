module Ashton
  class ParticleEmitter
    def empty?; count == 0 end

    WHITE_PIXEL_BLOB = "\xFF" * 4
    DEFAULT_MAX_PARTICLES = 1000

    def initialize(x, y, z, options = {})
      @@pixel ||= Gosu::Image.new $window, Ashton::ImageStub.new(WHITE_PIXEL_BLOB, 1, 1)

      # I'm MUCH too lazy to implement a huge options hash manager in C, especially on a constructor.
      options = {
          image: @@pixel,
          color: Gosu::Color::WHITE,
          max_particles: 100,
          gravity: 0,
          fade: 0.0,                     fade_deviation: 0.0,
          friction: 0.0,                 friction_deviation: 0.0,
          interval: Float::INFINITY,     interval_deviation: 0.0,
          offset: 0.0,                   offset_deviation: 0.0,
          scale: 1.0,                    scale_deviation: 0.0,
          speed: 0.0,                    speed_deviation: 0.0,
          time_to_live: Float::INFINITY, time_to_live_deviation: 0.0,
          zoom: 0.0,                     zoom_deviation: 0.0,
          
      }.merge! options
      
      @image = options[:image] || @@pixel
      @color = options[:color] || Color::Gosu::WHITE
      @shader = options[:shader]

      initialize_ x, y, z, options[:max_particles]

      self.gravity = options[:gravity]

      self.zoom = options[:fade]
      self.zoom_deviation = options[:fade_deviation]

      self.friction = options[:friction]
      self.friction_deviation = options[:friction_deviation]

      self.interval = options[:interval]
      self.interval_deviation = options[:interval_deviation]

      self.offset = options[:offset]
      self.offset_deviation = options[:offset_deviation]

      self.scale = options[:scale]
      self.scale_deviation = options[:scale_deviation]

      self.speed = options[:speed]
      self.speed_deviation = options[:speed_deviation]

      self.time_to_live = options[:time_to_live]
      self.time_to_live_deviation = options[:time_to_live_deviation]

      self.zoom = options[:zoom]
      self.zoom_deviation = options[:zoom_deviation]
    end
  end
end