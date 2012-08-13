# Use of a stencil shader and multitexturing in Gosu.

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
    self.caption = "Stencil shader - <space> new stencil layout"

    setup_example_objects

    @image = Gosu::Image.new self, media_path("LargeStar.png"), false
    @stencil = Gosu::Image.new self, media_path("SmallStar.png"), false

    # The texture to draw the stencil on. It's best to use an
    # Ashton::WindowBuffer, since it is the same size as the window itself.
    @stencil_texture = Ashton::WindowBuffer.new

    # Fill the stencil texture
    place_stencils

    @shader = Ashton::Shader.new vertex: :multitexture2, fragment: :stencil
  end

  def draw
    # Draw the background and ship
    draw_example_objects


    # We'll use the window's primary buffer to draw our images that need to be masked.
    # We can use this buffer as long as we don't expect it to be cleared before we use it
    # or unaltered between our uses of it.
    primary_buffer.render do |buffer|
      buffer.clear
      @image.draw_rot(@image.width / 2, @image.height / 2, 0, @rotation)
    end

    # Draw the primary buffer with our shader and give it our stencil to work with.
    primary_buffer.draw 0, 0, 0, shader: @shader, multitexture: @stencil_texture

    # Show the stencil texture drawn directly on the screen, for comparison.
    @stencil_texture.draw 320, 0, 0, mode: :replace
    @font.draw "Stencil texture", 450, 0, 0
  end

  # Clear the stencil texture and draw new stencils on top of it
  def place_stencils
    @stencil_texture.render do |texture|
      texture.clear
      5.times do
        @stencil.draw_rot(rand(@image.width), rand(@image.height), 1, 0, 0.5, 0.5, 2, 2)
      end
    end
  end

  # Not important --------

  def update
    $gosu_blocks.clear # Workaround for Gosu bug (0.7.45)
    @rotation = (@rotation + 1) % 360
  end

  def button_down(id)
    case id
      when Gosu::KbEscape
        close

      when Gosu::KbSpace
        place_stencils
    end
  end

  private
  def draw_example_objects
    @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)
    @ship.draw(100, 200 + 200 * Math.sin(@rotation.gosu_to_radians), 0)
  end

  def setup_example_objects
    @font = Gosu::Font.new $window, Gosu::default_font_name, 20
    @background = Gosu::Image.new self, media_path("Earth.png"), true
    @ship = Gosu::Image.new self, media_path("Starfighter.bmp"), false
    @rotation = 0
  end
end

window = GameWindow.new
window.show