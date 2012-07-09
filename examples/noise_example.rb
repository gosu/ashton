# Use of GLSL shader in Gosu to post-process the entire screen.

begin
  require 'rubygems'
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require "ashton"

def shader(file); File.read File.expand_path("../lib/ashton/post_process/#{file}", File.dirname(__FILE__)) end
def media_path(file); File.expand_path "media/#{file}", File.dirname(__FILE__) end

class TestWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Post-processing with 'noise'"

    @shader = Ashton::PostProcess.new shader('noise.frag')
    @shader['in_Intensity'] = 2.0

    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    update # Ensure the values are initially set.
  end

  def update
    @shader['in_T'] = Math::sin(Gosu::milliseconds / 500.0) * 1000
  end

  def draw
    post_process @shader do
      @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)

      @font.draw_rel "Hello world!", 350, 50, 0, 0.5, 0.5, 1, 1, Gosu::Color::GREEN
      @font.draw_rel "Goodbye world!", 400, 350, 0, 0.5, 0.5, 2, 2, Gosu::Color::BLUE

      @star.draw 0, 0, 0
      @star.draw 200, 100, 0
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

TestWindow.new.show