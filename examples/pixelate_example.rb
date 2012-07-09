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
    self.caption = "Post-processing with 'pixelate' - hold space to disable"

    @pixelate = Ashton::PostProcess.new shader('pixelate.frag')
    @pixelate['in_PixelSize'] = 4
    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)

    update # Ensure the values are initially set.
  end

  def update
    super
  end

  def draw_scene
    @font.draw_rel "Hello world!", 330, 25, 0, 0.5, 0.5
    @font.draw_rel "Goodbye world!", 400, 350, 0, 0.5, 0.5
    @star.draw 0, 0, 0
    @star.draw 200, 100, 0
  end

  def draw
    
    if button_down? Gosu::KbSpace
      draw_scene
    else
      post_process @pixelate do
        draw_scene
      end
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end
end

TestWindow.new.show