# Use of GLSL shader in Gosu to post-process the entire screen.

begin
  require 'rubygems'
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require "ashton"

def shader(file); File.read File.expand_path("../lib/ashton/post_process/#{file}", File.dirname(__FILE__)) end

class TestWindow < Gosu::Window
  def initialize
    super 640, 480, false
    self.caption = "Post-processing with 'radial_blur' - hold space to disable; 1-5 sets brightness"

    @blur = Ashton::PostProcess.new shader('radial_blur.frag')
    @blur['in_BrightFactor'] = 1.0
    @blur['in_Passes'] = 20 # Quite a lot of work, but just proves how fast shader are!
    @font = Gosu::Font.new self, Gosu::default_font_name, 40

    update # Ensure the values are initially set.
  end

  def update
    # Wiggle the blur about a bit each frame!
    @blur['in_BlurFactor'] = Math::sin(Gosu::milliseconds / 500.0) * 0.1
    @blur['in_OriginX'] = mouse_x
    @blur['in_OriginY'] = mouse_y
  end

  def button_down(code)
    case code
      when Gosu::Kb1 then @blur['in_BrightFactor'] = 1.0
      when Gosu::Kb2 then @blur['in_BrightFactor'] = 2.0
      when Gosu::Kb3 then @blur['in_BrightFactor'] = 3.0
      when Gosu::Kb4 then @blur['in_BrightFactor'] = 4.0
      when Gosu::Kb5 then @blur['in_BrightFactor'] = 5.0
    end
  end

  def draw_scene
    @font.draw_rel "Hello world!", 100, 100, 0, 0, 0.5, 0.5
    @font.draw_rel "Goodbye world!", 400, 280, 0, 0.5, 0.5

    @font.draw_rel "X", mouse_x, mouse_y, 0, 0.5, 0.5
  end

  def draw

    if button_down? Gosu::KbSpace
      draw_scene
    else
      post_process @blur do
         draw_scene
      end
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end
end

TestWindow.new.show