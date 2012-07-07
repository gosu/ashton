# Use of GLSL shaders in Gosu.

begin
  require 'rubygems'
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require "ashton"

def media_path(file); File.expand_path "media/#{file}", File.dirname(__FILE__) end
def output_path(file); File.expand_path "output/#{file}", File.dirname(__FILE__) end

module ZOrder
  Stars, Player, UI = *0..3
end

# The only really new class here.
# Draws a scrolling, repeating texture with a randomized height map.
class GLBackground
  # Height map size
  POINTS_X = 7
  POINTS_Y = 7
  # Scrolling speed
  SCROLLS_PER_STEP = 50

  def initialize(window)
    @image = Gosu::Image.new(window, media_path("Earth.png"), true)
    
    @framebuffer = Ashton::Framebuffer.new $window.width, $window.height
    
    @shader = Ashton::Shader.new # Just use default shaders for now.
    
    @shader.image = @image        
  end
  
  def draw_with_shaders
    width, height = $window.width, $window.height
    
    # Doing it with shaders.
    @shader.use do |s|
      s.color = [1, 1, 1, 1] # color can be set inside or outside of glBegin.
      s.image = @image       # image can only be set outside of glBegin.
      glBegin GL_QUADS do
        # Drawing a quad in a single colour (TOP RIGHT).        
        glVertex2d width / 2, height / 2 # BL
        glVertex2d width / 2, 0 # TL
        glVertex2d width, 0 # TR
        glVertex2d width, height / 2 # BR  
        
        # Quad with coloured corners (BOTTOM RIGHT).
        s.color = [0, 1, 1, 1]
        glVertex2d width / 2, height # BL
        s.color = [1, 1, 0, 1]
        glVertex2d width / 2, height / 2 # TL
        s.color = [0, 0, 0, 0]
        glVertex2d width, height / 2 # TR
        s.color = [1, 0, 0, 1]
        glVertex2d width, height# BR
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
  
  def draw    
    @framebuffer.use do |fb|
      fb.clear
      draw_with_shaders
      draw_without_shaders
      @shader.image.draw 0, 0, 0 # Just draw somethihng normally to hopefully get it into the fbo!
    end
    
    # Convert the OpenGL framebuffer into a Gosu image, save it then display it.
    image = @framebuffer.to_image
    filename = output_path("framebuffer.png")
    image.save filename unless File.exists? filename
    image.draw 0, 0, 0
    
    image = @framebuffer.to_image rect: [400, 400, 200, 200]
    filename = output_path("framebuffer_section.png")
    image.save filename unless File.exists? filename
        
    #@framebuffer.draw 0, 0 # Is upside-down!
  end
end

class GameWindow < Gosu::Window
  def initialize
    super 800, 600, false
    self.caption = "Gosu & OpenGL Integration Demo (SHADERS)"
    
    $window = self
    
    @gl_background = GLBackground.new self
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)    
    @image = Gosu::Image.new(self, media_path("Earth.png"), true)          
  end

  def draw
    glClearColor 0.0, 0.2, 0.5, 1.0
    glClearDepth 0
    glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
    
    @gl_background.draw
    
    @image.draw 0, 100, Float::INFINITY    
    
    @font.draw Gosu::fps.to_s, 0, 50, Float::INFINITY
    @font.draw "Gosu::Image#draw", 0, 0, Float::INFINITY
    @font.draw_rel "flat shader", width, 0, Float::INFINITY, 1, 0
    @font.draw_rel "coloured shader", width, height, Float::INFINITY, 1, 1
    @font.draw_rel "standard quad", 0, height, Float::INFINITY, 0, 1
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

window = GameWindow.new
window.show