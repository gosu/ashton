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
    self.caption = "Post-processing with 'bloom' - mouse pos alters glare and power - hold <Space> to disable"

    @bloom = Ashton::Shader.new fragment: :bloom


    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    update # Ensure the values are initially set.
  end

  def update
    $gosu_blocks.clear if defined? $gosu_blocks # Workaround for Gosu bug (0.7.45)
    @bloom.glare_size = [0.008 * mouse_x / width, 0.0].max
    @bloom.power = [0.5 * mouse_y / height, 0.0].max
  end

  def needs_cursor?; true end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def draw
    shaders = button_down?(Gosu::KbSpace) ? [] : [@bloom]
    post_process(*shaders) do
      @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)
      @star.draw 0, 0, 0
      @star.draw 200, 100, 0, 1, 1, Gosu::Color.rgb(100, 100, 100)
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw_rel "Less glare", 0, height / 2, 0, 0, 0.5
    @font.draw_rel "More glare", width, height / 2, 0, 1, 0.5

    @font.draw_rel "Less power", width / 2, 0, 0, 0.5, 0
    @font.draw_rel "More power", width / 2, height, 0, 0.5, 1
  end
end

TestWindow.new.show