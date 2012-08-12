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
    self.caption = "Post-processing with both 'tv_screen.frag' and 'static.frag'"

    @screen = Ashton::Shader.new fragment: :tv_screen, uniforms: {
        column_width: 1.0,
    }

    @static = Ashton::Shader.new fragment: :static

    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    update # Ensure the values are initially set.
  end

  def update
    $gosu_blocks.clear # Workaround for Gosu bug (0.7.45)

    @static.t = Math::sin(Gosu::milliseconds / 500.0) * 1000
    @static.intensity = Math::sin(Gosu::milliseconds / 2345.0) + 1.5
  end

  def draw
    post_process @static, @screen do
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