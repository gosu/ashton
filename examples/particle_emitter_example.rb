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

    @image_emitter = Ashton::ParticleEmitter.new 450, 100, 0,
                                                 image: @star,
                                                 scale: 0.2,
                                                 speed: 20,
                                                 friction: 0.1,
                                                 max_particles: 10000,
                                                 interval: 0.002,
                                                 fade: 25, # loses 25 alpha/s
                                                 angular_velocity: -50..50

    @shaded_image_emitter = Ashton::ParticleEmitter.new 450, 350, 0,
                                                        image: @star,
                                                        shader: @grayscale,
                                                        interval: 0.0005,
                                                        offset: 0..10,
                                                        max_particles: 10000,
                                                        angular_velocity: 20..50,
                                                        center_x: 3..8, center_y: 3..8,
                                                        zoom: -0.3 # Shrinks, so doesn't need TTL.

    @point_emitter = Ashton::ParticleEmitter.new 100, 100, 1,
                                                 scale: 10,
                                                 speed: 200,
                                                 interval: 0.0002,
                                                 max_particles: 10000,
                                                 interval: 0.0005,
                                                 color: Gosu::Color.rgba(255, 0, 0, 150),
                                                 fade: 100 # loses 100 alpha/s

    @shaded_point_emitter = Ashton::ParticleEmitter.new 100, 300, 2,
                                                        scale: 4..10,
                                                        shader: @grayscale,
                                                        speed: 60..100,
                                                        offset: 0..10,
                                                        time_to_live: 12,
                                                        interval: 0.0005,
                                                        max_particles: 10000,
                                                        color: Gosu::Color.rgba(255, 0, 0, 255),
                                                        gravity: 60 # pixels/s*s
  end

  def update
    $gosu_blocks.clear # workaround for Gosu 0.7.45 bug.

    # Calculate delta from milliseconds.
    @last_update_at ||= Gosu::milliseconds
    delta = [Gosu::milliseconds - @last_update_at, 100].min * 0.001 # Limit delta to 100ms (10fps), in case of freezing.
    @last_update_at = Gosu::milliseconds

    @image_emitter.update delta unless button_down? Gosu::Kb1
    @shaded_image_emitter.update delta unless button_down? Gosu::Kb2
    @point_emitter.update delta unless button_down? Gosu::Kb3
    @shaded_point_emitter.update delta unless button_down? Gosu::Kb4
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def draw
    @point_emitter.draw
    @shaded_image_emitter.draw
    @shaded_point_emitter.draw
    @image_emitter.draw

    @font.draw "FPS: #{Gosu::fps} Pnt: #{@point_emitter.count} ShaPnt: #{@shaded_point_emitter.count} Img: #{@image_emitter.count} ShaImg: #{@shaded_image_emitter.count}", 0, 0, Float::INFINITY
  end
end

TestWindow.new.show