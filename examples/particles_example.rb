begin
  require 'rubygems'
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require "ashton"

def media_path(file); File.expand_path "media/#{file}", File.dirname(__FILE__) end

class TestWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Particle emitters"

    @grayscale = Ashton::Shader.new fragment: :grayscale

    @font = Gosu::Font.new self, Gosu::default_font_name, 24
    @star = Gosu::Image.new self, media_path("SmallStar.png"), true
    @background = Gosu::Image.new self, media_path("Earth.png"), true

    @image_emitter = Ashton::ParticleEmitter.new 450, 100, 0,
                                                 image: @star,
                                                 scale: 0.3,
                                                 speed: 100, time_to_live: 10,
                                                 acceleration: -2,
                                                 max_particles: 3000,
                                                 interval: 0.01,
                                                 fade: 0.5,
                                                 angular_velocity: 200, angular_velocity_deviation: 0

    @shaded_image_emitter = Ashton::ParticleEmitter.new 450, 350, 0,
                                                        image: @star, friction: 2,
                                                        shader: @grayscale,
                                                        speed: 200, time_to_live: 5,
                                                        interval: 0.001,
                                                        max_particles: 5000,
                                                        offset: 25, offset_deviation: 1,
                                                        zoom: -0.5

    @point_emitter = Ashton::ParticleEmitter.new 100, 100, 0,
                                                 scale: 12,
                                                 speed: 200, time_to_live: 4,
                                                 interval: 0.001,
                                                 max_particles: 3000,
                                                 interval: 0.003,
                                                 color: Gosu::Color.rgba(255, 0, 0, 50)

    @shaded_point_emitter = Ashton::ParticleEmitter.new 100, 300, 0,
                                                        scale: 12, scale_deviation: 0.8,
                                                        shader: @grayscale,
                                                        speed: 200, speed_deviation: 0.5,
                                                        time_to_live: 4,
                                                        interval: 0.001,
                                                        max_particles: 3000,
                                                        interval: 0.003,
                                                        color: Gosu::Color.rgba(255, 0, 0, 255),
                                                        gravity: 2
  end

  def update
    @image_emitter.update        unless button_down? Gosu::Kb1
    @shaded_image_emitter.update unless button_down? Gosu::Kb2
    @point_emitter.update        unless button_down? Gosu::Kb3
    @shaded_point_emitter.update unless button_down? Gosu::Kb4
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def draw
    @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height), Gosu::Color.rgba(255, 255, 255, 175)

    @shaded_image_emitter.draw
    @shaded_point_emitter.draw
    @point_emitter.draw
    @image_emitter.draw

    @font.draw "FPS: #{Gosu::fps} Img: #{@image_emitter.count} ShaImg: #{@shaded_image_emitter.count} Pnt: #{@point_emitter.count} ShaPnt: #{@shaded_point_emitter.count}", 0, 0, 0
  end
end

TestWindow.new.show