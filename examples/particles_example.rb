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

    @sepia = Ashton::Shader.new fragment: :sepia

    @font = Gosu::Font.new self, Gosu::default_font_name, 24
    @star = Gosu::Image.new self, media_path("SmallStar.png"), true
    @background = Gosu::Image.new self, media_path("Earth.png"), true

    @image_emitter = Ashton::ParticleEmitter.new 100, 300, 0,
                                            image: @star,
                                            scale: 0.3,
                                            speed: 1, time_to_live: 1,
                                            acceleration: -2,
                                            max_particles: 1000,
                                            interval: 0.0001

    @shaded_image_emitter = Ashton::ParticleEmitter.new 400, 200, 0,
                                            image: @star,
                                            scale: 0.3, shader: @sepia,
                                            speed: 2, time_to_live: 1,
                                            interval: 0.0002

    @point_emitter = Ashton::ParticleEmitter.new 100, 50, 0,
                                            scale: 8, color: Gosu::Color::RED,
                                            speed: 1, time_to_live: 0.4,
                                            interval: 0.0006,
                                            max_particles: 1000,
                                            interval: 0.00003
  end

  def update
    @image_emitter.update        unless button_down? Gosu::Kb1
    @shaded_image_emitter.update unless button_down? Gosu::Kb2
    @point_emitter.update        unless button_down? Gosu::Kb3
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def draw
    @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height), Gosu::Color.rgba(255, 255, 255, 175)

    @image_emitter.draw
    @shaded_image_emitter.draw
    @point_emitter.draw

    @font.draw "FPS: #{Gosu::fps} Im: #{@image_emitter.size} ImSha: #{@shaded_image_emitter.size} Pt: #{@point_emitter.size}", 0, 0, 0
  end
end

TestWindow.new.show