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
    self.caption = "Post-processing with Blur - hold space to disable; 1-5 sets brightness"

    @blur = Ashton::PostProcess.new shader('pixelate.frag')
    @blur['in_PixelSize'] = 16.0
    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)

    update # Ensure the values are initially set.
  end

  def update
  end

  def draw
    @font.draw_rel "Hello world!", 100, 100, 0, 0, 0.5, 0.5
    @font.draw_rel "Goodbye world!", 400, 280, 0, 0.5, 0.5
    @star.draw 0, 0, 0
    @star.draw 200, 100, 0

    unless button_down? Gosu::KbSpace
      10.times { @blur.process }
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end
end

TestWindow.new.show