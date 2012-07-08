# Use of GLSL shader in Gosu.

begin
  require 'rubygems'
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require "ashton"

def media_path(file); File.expand_path "media/#{file}", File.dirname(__FILE__) end

class GameWindow < Gosu::Window
  def initialize
    super 800, 600, false
    self.caption = "Ashton::Framebuffer example - composing an image inside a buffer - hold LMB to draw"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)
    @framebuffer = Ashton::Framebuffer.new width, height
  end

  def update
    if button_down? Gosu::MsLeft
      # Draw into the framebuffer, rather than onto the screen.
      @framebuffer.use do
        @star.draw_rot mouse_x, mouse_y, 0, 0, 0.5, 0.5
      end
    end
  end

  def draw
    @framebuffer.draw 0, 0 # Draws immediately.
    @star.draw_rot mouse_x, mouse_y, 0, 0, 0.5, 0.5

    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show