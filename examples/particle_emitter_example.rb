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
    self.caption = "Particle emitters - 4 emitters at static positions and one on mouse"

    @grayscale = Ashton::Shader.new fragment: :grayscale

    @font = Gosu::Font.new self, Gosu::default_font_name, 24
    @star = Gosu::Image.new self, media_path("SmallStar.png"), true

    @image_emitter = Ashton::ParticleEmitter.new 450, 100, 0,
                                                 image: @star,
                                                 scale: 0.2,
                                                 speed: 20,
                                                 friction: 0.1,
                                                 max_particles: 15000,
                                                 interval: 0.002,
                                                 fade: 25, # loses 25 alpha/s
                                                 angular_velocity: -50..50

    @shaded_image_emitter = Ashton::ParticleEmitter.new 450, 350, 0,
                                                        image: @star,
                                                        shader: @grayscale,
                                                        interval: 0.00025,
                                                        offset: 0..10,
                                                        max_particles: 15000,
                                                        angular_velocity: 20..50,
                                                        center_x: 3..8, center_y: 3..8,
                                                        zoom: -0.3 # Shrinks, so doesn't need TTL.

    @point_emitter = Ashton::ParticleEmitter.new 100, 100, 1,
                                                 scale: 10,
                                                 speed: 200,
                                                 interval: 0.0002,
                                                 max_particles: 15000,
                                                 interval: 0.0002,
                                                 color: Gosu::Color.rgba(255, 0, 0, 150),
                                                 fade: 50 # loses 50 alpha/s

    @shaded_point_emitter = Ashton::ParticleEmitter.new 100, 300, 2,
                                                        scale: 4..10,
                                                        shader: @grayscale,
                                                        speed: 60..100,
                                                        offset: 0..10,
                                                        time_to_live: 12,
                                                        interval: 0.0003,
                                                        max_particles: 15000,
                                                        color: Gosu::Color.rgba(255, 0, 0, 100),
                                                        gravity: 60 # pixels/s*s

    @mouse_emitter = Ashton::ParticleEmitter.new 0, 0, 3,
                                                 scale: 4,
                                                 speed: 20..50,
                                                 offset: 0..5,
                                                 interval: 0.0025,
                                                 color: Gosu::Color.rgba(0, 255, 255, 100),
                                                 fade: 50,
                                                 gravity: 60 # pixels/s*s
  end

  def needs_cursor?; true end

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

    @mouse_emitter.x, @mouse_emitter.y = mouse_x, mouse_y
    @mouse_emitter.update delta unless button_down? Gosu::Kb5
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
    @mouse_emitter.draw

    num_particles = @point_emitter.count + @shaded_point_emitter.count +
                    @image_emitter.count + @shaded_image_emitter.count +
                    @mouse_emitter.count
    @font.draw "FPS: #{Gosu::fps}   Particles: #{num_particles}", 0, 0, Float::INFINITY

    totals = "Pnt: #{@point_emitter.count} ShaPnt: #{@shaded_point_emitter.count} Img: #{@image_emitter.count} ShaImg: #{@shaded_image_emitter.count} Mouse: #{@mouse_emitter.count}"
    @font.draw_rel totals, 0, height, Float::INFINITY, 0, 1
  end
end

TestWindow.new.show