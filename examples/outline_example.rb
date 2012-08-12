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

    self.caption = "Image, font and buffer composition drawn with 'outline' shader"

    @outline = Ashton::Shader.new fragment: :outline

    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @ship = Gosu::Image.new(self, media_path("Starfighter.png"), true)
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    @buffer = Ashton::Texture.new width, height

    render_to_buffer
  end

  def update
    $gosu_blocks.clear # Workaround for Gosu bug (0.7.45)
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

    @outline.outline_width = 2.0
    @outline.outline_color = Gosu::Color::YELLOW
    @buffer.draw 0, 0, 0, shader: @outline

    # Draw individually, each with their own outline.
    10.downto(1) do |i|
      scale = i / 2.0
      angle = i * 15 + Time.now.to_f * 10

      @outline.outline_color = [Gosu::Color::RED, Gosu::Color::WHITE][i % 2]

      # This keeps the outline of constant width on the screen,
      # compared to the sprite pixels. Wouldn't keep updating this in real usage, of course.
      @outline.outline_width = 0.9 / scale

      @ship.draw_rot 225 + i * 25, 15 + i * 30, 0, angle, 0.5, 0.5, scale, scale, :shader => @outline
    end

    # Guitastic!
    @outline.outline_width = 2.0
    @outline.outline_color = Gosu::Color::BLACK
    @font.draw "FPS:", 0, 0, 0, 1, 1, Gosu::Color::BLUE, shader: @outline
    @font.draw_rel "#{Gosu::fps}", 150, 0, 0, 1, 0, 1, 1, Gosu::Color::GREEN, shader: @outline
  end
end

TestWindow.new.show