# Use of GLSL shader in Gosu.

require_relative '../lib/ashton'

def media_path(file); File.expand_path "media/#{file}", File.dirname(__FILE__) end

class GameWindow < Gosu::Window
  def initialize
    super 800, 600, false

    # Enable pixelation for all Gosu Images (must be called before creating any Images).
    # Comment this line out to see default Gosu behaviour (smoothing).
    #Gosu.enable_undocumented_retrofication

    self.caption = "Ashton::Texture pixelation example"
    if Ashton::Texture.pixelated?
      self.caption += "(Gosu::enable_undocumented_retrofication called)"
    else
      self.caption += "(Gosu::enable_undocumented_retrofication NOT called)"
    end

    @image = Gosu::Image.new self, media_path("Starfighter.bmp"), true
    @texture = @image.to_texture
    @font = Gosu::Font.new $window, Gosu::default_font_name, 15
  end

  def update
    $gosu_blocks.clear if defined? $gosu_blocks # Workaround for Gosu bug (0.7.45)
  end

  def draw
    # Drawing Textures will pixelate by default if Gosu::enable_undocumented_retrofication has ever been called.
    @font.draw "Gosu::Image", 0, 0, 0
    @font.draw "Ashton::Texture default", 200, 0, 0
    @font.draw "Ashton::Texture pixelated: true", 400, 0, 0
    @font.draw "Ashton::Texture pixelated: false", 600, 0, 0

    # Zoom in a Texture, so smoothing/pixelation occurs based on preference.
    scale 4 do
      @image.draw 0, 25, 0
      @texture.draw 50, 25, 0
      @texture.draw 100, 25, 0, pixelated: true
      @texture.draw 150, 25, 0, pixelated: false
    end

    # Zooming out a Texture will _always_ smooth (with Gosu::Image it will pixelate on zooming out, which looks terrible!)
    scale 0.5 do
      @image.draw 0, 900, 0
      @texture.draw 400, 900, 0
      @texture.draw 800, 900, 0, pixelated: true
      @texture.draw 1200, 900, 0, pixelated: false
    end

    @font.draw "Ashton::Texture is <i>always</i> smoothed when zoomed out, so it doesn't distort", 0, 400, 0
  end

  def button_down(id)
    case id
      when Gosu::KbEscape
        close
    end
  end
end

window = GameWindow.new
window.show