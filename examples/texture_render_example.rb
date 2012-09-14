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
    self.caption = "Ashton::Texture example - composing an image - hold <LMB> to draw - <delete> to clear"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)
    @texture = Ashton::Texture.new width, height
  end

  def update
    $gosu_blocks.clear if defined? $gosu_blocks # Workaround for Gosu bug (0.7.45)

    if button_down? Gosu::MsLeft
      # Draw into the texture, rather than onto the screen.
      @texture.render do
        @star.draw_rot mouse_x, mouse_y, 0, 0, 0.5, 0.5
      end
    end
  end

  def needs_cursor?; true end

  def draw
    @texture.draw 0, 0, 0
    @star.draw_rot mouse_x, mouse_y, 0, 0, 0.5, 0.5

    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end

  def button_down(id)
    case id
      when Gosu::KbDelete
        @texture.clear color: Gosu::Color.rgb(rand() * 255, rand() * 255, rand() * 255)
      when Gosu::KbEscape
        close
    end
  end
end

window = GameWindow.new
window.show