# Use of GLSL shader in Gosu.

begin
  require 'rubygems'
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require "ashton"

def media_path(file); File.expand_path "media/#{file}", File.dirname(__FILE__) end
def output_path(file); File.expand_path "output/#{file}", File.dirname(__FILE__) end

class GameWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Gosu & OpenGL Integration Demo (SHADERS)"

    @font = Gosu::Font.new self, Gosu::default_font_name, 20
    @image = Gosu::Image.new self, media_path("Earth.png"), true
    @shader = Ashton::Shader.new # Just use default shader for now.
  end

  def draw
    # draw, with and without colour.
    @image.draw 10, 10, 0, :shader => @shader
    @image.draw 10, @image.height + 20, 0, 1, 1, Gosu::Color::RED, :shader => @shader

    # draw#rot, with and without colour.
    @image.draw_rot 280, 0, 0, 10, 0, 0, :shader => @shader
    @image.draw_rot 280, @image.height + 10, 0, 10, 0, 0, 1, 1, Gosu::Color::RED, :shader => @shader
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show