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

    Gosu::enable_undocumented_retrofication

    self.caption = "Post-processing with 'outline' - outline is scaled to stay the same width, regardless of zoom"

    @red_outline = Ashton::Shader.new fragment: :outline, uniforms: {
        outline_color: [1.0, 0.0, 0.0, 1.0],
    }
    @white_outline = Ashton::Shader.new fragment: :outline, uniforms: {
        outline_color: [1.0, 1.0, 1.0, 1.0],
    }

    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @ship = Gosu::Image.new(self, media_path("Starfighter.png"), true)
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    @buffer = Ashton::Framebuffer.new width, height

    render_to_buffer
  end

  def update
    render_to_buffer
  end

  def render_to_buffer
    # Draw together into a temp buffer, before outlining all together.
    @buffer.render do |buffer|
      buffer.clear

      10.downto(1) do |i|
        scale = i / 2.0
        angle = i * 15 + Time.now.to_f * 10

        @ship.draw_rot i * 25, 15 + i * 30, 0, angle, 0.5, 0.5, scale, scale
      end
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end

  def draw
    @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)

    @white_outline.outline_width = 2.0
    @buffer.draw 0, 0, 0, shader: @white_outline

    # Draw individually, each with their own outline.
    10.downto(1) do |i|
      scale = i / 2.0
      angle = i * 15 + Time.now.to_f * 10
      shader = [@white_outline, @red_outline][i % 2]

      # This keeps the outline of constant width on the screen,
      # compared to the sprite pixels. Wouldn't keep updating this in real usage, of course.
      shader.outline_width = 0.9 / scale

      @ship.draw_rot 225 + i * 25, 15 + i * 30, 0, angle, 0.5, 0.5, scale, scale, :shader => shader
    end

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end
end

TestWindow.new.show