# Use of GLSL shader in Gosu to post-process the entire screen.

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
    self.caption = "Shadow-casting - <space> new layout; <LMB> place light; <D> toggle debug"

    @font = Gosu::Font.new self, Gosu::default_font_name, 32
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)

    # Input: Shadow casters are any object that casts a shadow.
    place_shadow_casters

    setup_lighting

    # Perform the initial rendering into the light manager.
    @lighting.update_shadow_casters do
      draw_shadow_casters
    end

    @debug = false
  end

  def setup_lighting
    @lighting = Ashton::Lighting::Manager.new

    # Add some lights (various methods)
    @lighting.create_light 240, 240, 0, height / 3, color: Gosu::Color::RED

    light =  Ashton::Lighting::LightSource.new 400, 150, 0, height / 5, color: Gosu::Color::GREEN
    @lighting << light

    @light_mouse = @lighting.create_light mouse_x, mouse_y, 0, height / 2, color: Gosu::Color::GRAY
  end

  # Creates a new set of objects that cast shadows.
  def place_shadow_casters
    @shadow_casters = Array.new 12 do
      { x: rand() * width, y: rand() * height, angle: rand() * 360 }
    end
  end

  def update
    @light_mouse.x, @light_mouse.y = mouse_x, mouse_y

    @lighting.update_shadow_casters do
      draw_shadow_casters
    end
  end

  def draw_shadow_casters
    @font.draw "Hello world! Time to get a grip, eh?", 0, 150, 0, 1, 1, Gosu::Color::RED
    @shadow_casters.each do |star|
      @star.draw_rot star[:x], star[:y], 0, star[:angle], 0.5, 0.5, 0.125, 0.125
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
      when Gosu::KbEscape
        close

      when Gosu::KbSpace
        place_shadow_casters

      when Gosu::MsLeft
        color = Gosu::Color.rgba rand(255), rand(255), rand(255), 127 + rand(128)
        @lighting.create_light mouse_x, mouse_y, 0, height / 16 + rand(height / 2), color: color

      when Gosu::KbD
        @debug = !@debug

      when Gosu::KbS
        @lighting.each {|light| light.send :save_buffers }
    end
  end

  def draw
    @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)

    # ... would draw player and other objects here ...

    @lighting.draw

    draw_shadow_casters

    # Draw the light itself - this isn't managed by the manager.
    @lighting.each do |light|
      pixel.draw_rot light.x, light.y, 0, 0, 0.5, 0.5, 15, 15, light.color, :add
      light.draw_debug if @debug
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "FPS: #{Gosu::fps} (for #{@lighting.size} lights)", 0, 0, 0
  end
end

TestWindow.new.show