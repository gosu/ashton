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
    self.caption = "Post-processing with 'pixelate' - 1..9 affect pixel size"

    @pixelate = Ashton::Shader.new fragment: :pixelate
    @pixelate['in_PixelSize'] = @pixel_size = 4

    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)

    update # Ensure the values are initially set.
  end

  def button_down(id)
    if (Gosu::Kb1..Gosu::Kb9).include? id
      @pixel_size = (id - Gosu::Kb1 + 1) ** 2
      @pixelate['in_PixelSize'] = @pixel_size
    elsif id == Gosu::KbEscape
      close
    end
  end

  def draw
    post_process @pixelate do
      @font.draw_rel "Hello world!", 350, 50, 0, 0.5, 0.5
      @font.draw_rel "Goodbye world!", 400, 350, 0, 0.5, 0.5
      @star.draw 0, 0, 0
      @star.draw 200, 100, 0
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "Pixel ratio: 1:#{@pixel_size}", 0, 0, 0
  end
end

TestWindow.new.show