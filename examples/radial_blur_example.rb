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
    self.caption = "Post-processing with 'radial_blur' - mouse pos affects spacing/strength"

    @blur = Ashton::Shader.new fragment: :radial_blur
    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    update # Ensure the values are initially set.
  end

  def update
    @blur.spacing = [2.0 * mouse_x / width, 0.0].max
    @blur.strength = [4.4 * mouse_y / height, 0.0].max
  end

  def needs_cursor?; true end

  def button_down(id)
    if (Gosu::Kb1..Gosu::Kb9).include? id
      @blur_factor = (id - Gosu::Kb1 + 1).to_f
      @blur.blur_factor = @blur_factor
    elsif id == Gosu::KbEscape
      close
    end
  end

  def draw
    shaders = button_down?(Gosu::KbSpace) ? [] : [@blur]
    post_process(*shaders)  do
      @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)

      @font.draw_rel "Hello world!", 100, 100, 0, 0.5, 0.5, 1, 1, Gosu::Color::RED
      @font.draw_rel "Goodbye world!", 400, 280, 0, 0.5, 0.5, 1, 1, Gosu::Color::BLUE
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw_rel "Less spacing", 0, height / 2, 0, 0, 0.5
    @font.draw_rel "More spacing", width, height / 2, 0, 1, 0.5

    @font.draw_rel "Less strength", width / 2, 0, 0, 0.5, 0
    @font.draw_rel "More strength", width / 2, height, 0, 0.5, 1
  end
end

TestWindow.new.show