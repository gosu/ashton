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
    super 800, 600, false
    self.caption = "Gosu & OpenGL Integration Demo (SHADERS)"

    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @image = Gosu::Image.new(self, media_path("Earth.png"), true)
    @shader = Ashton::Shader.new # Just use default shader for now.
    @shader.image = @image
  end

  def draw
    glClearColor 0.0, 0.2, 0.5, 1.0
    glClearDepth 0
    glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

    draw_with_shaders
    draw_without_shaders
    
    @image.draw 0, 0, 0, 2, 2

    @font.draw "Gosu::Image#draw", 0, 0, 0
    @font.draw_rel "OpenGL quad - flat shader", width, 0, 0, 1, 0
    @font.draw_rel "OpenGL quad - coloured shader", width, height, 0, 1, 1
    @font.draw_rel "OpenGL quad - no shader, but coloured", 0, height, 0, 0, 1
  end

  def draw_with_shaders
    width, height = $window.width, $window.height

    # Doing it with shader.
    @shader.use do |s|
      s.image = @image       # image can only be set outside of glBegin.
      s.color = [1, 1, 1, 1]
      glBegin GL_QUADS do
        # Drawing a quad in a single colour (TOP RIGHT).

        glVertex2d width / 2, height / 2 # BL
        glVertex2d width / 2, 0 # TL
        glVertex2d width, 0 # TR
        glVertex2d width, height / 2 # BR

        # Quad with coloured corners (BOTTOM RIGHT).
        glColor4d(0, 1, 1, 1)
        glVertex2d width / 2, height # BL
        glColor4d(1, 1, 0, 1)
        glVertex2d width / 2, height / 2 # TL
        glColor4d(1.0, 1.0, 1.0, 0.5)
        glVertex2d width, height / 2 # TR
        glColor4d(1, 0, 0, 1)
        glVertex2d width, height # BR
      end
    end
  end

  def draw_without_shaders
    width, height = $window.width, $window.height

    # Drawing a textured quad without a shader (BOTTOM LEFT).
    info = @image.gl_tex_info
    glEnable(GL_TEXTURE_2D)
    glBindTexture(GL_TEXTURE_2D, info.tex_name)
    glBegin GL_QUADS do
      glColor4d(0, 1, 1, 1)
      glTexCoord2d(info.left, info.bottom)
      glVertex2d 0, height # BL

      glColor4d(1, 1, 0, 1)
      glTexCoord2d(info.left, info.top)
      glVertex2d 0, height / 2 # TL

      glColor4d(1.0, 1.0, 1.0, 0.5)
      glTexCoord2d(info.right, info.top)
      glVertex2d width / 2, height / 2 # TR

      glColor4d(1, 0, 0, 1)
      glTexCoord2d(info.right, info.bottom)
      glVertex2d width / 2, height # BR

      glColor4d(1, 1, 1, 1) # Reset colour so it doesn't polute!
    end
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show