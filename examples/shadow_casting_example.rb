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
    self.caption = "Shadow-casting - <space> to create a new layout of shadow-casters"

    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)

    @star = Gosu::Image.new(self, media_path("LargeStar.png"), true)

    @size = 480 # Must be divisible by two.

    # Shadow casters are any object that casts a shadow.
    @shadow_casters_fb = Ashton::Framebuffer.new @size, @size
    place_shadow_casters

    @distortion_fb = Ashton::Framebuffer.new @size, @size
    @shadow_map_fb = Ashton::Framebuffer.new 2, @size
    @shadows_fb = Ashton::Framebuffer.new @size, @size
    @blurred_fb = Ashton::Framebuffer.new @size, @size
    @window_shadows = Ashton::Framebuffer.new width, height

    # This will be the shadow map texture passed into @draw_shadows
    glActiveTexture GL_TEXTURE1
    raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE1
    glBindTexture GL_TEXTURE_2D, @shadow_map_fb.instance_variable_get(:@texture)

    # And go back to the default texture for general work.
    glActiveTexture GL_TEXTURE0

    @distort = Ashton::Shader.new fragment: :shadow_distort,
                                  vertex: :shadow,
                                  uniforms: {
                                      texture_width: @size,
                                  }

    @reduction = Ashton::Shader.new fragment: :shadow_horizontal_reduction,
                                    vertex: :shadow_horizontal_reduction,
                                    uniforms: {
                                        texture_width: @size,
                                    }

    @draw_shadows = Ashton::Shader.new fragment: :shadow_draw_shadows,
                                       vertex: :shadow,
                                       uniforms: {
                                           shadow_map_texture: 1,
                                           texture_width: @size,
                                       }

    @blur = Ashton::Shader.new fragment: :shadow_blur,
                               vertex: :shadow,
                               uniforms: {
                                   texture_width: @size,
                               }

    render_shadows

    # Only save once. for purposes of this example only.
    @shadow_casters_fb.to_image.save "output/shadow_casters.png"
    @distortion_fb.to_image.save "output/distortion.png"
    @shadow_map_fb.to_image.save "output/shadow_map.png"
    @shadows_fb.to_image.save "output/shadows.png"
    @blurred_fb.to_image.save "output/blurred.png"
  end

  def place_shadow_casters
    @shadow_casters_fb.render do |buffer|
      buffer.clear
      8.times do
        @star.draw_rot rand() * @size, rand() * @size, 0, rand() * 360, 0.5, 0.5, 0.125, 0.125
      end
    end
  end

  def update
    20.times { render_shadows }
  end

  def render_shadows
    @distortion_fb.render do
      @shadow_casters_fb.draw 0, 0, 0, shader: @distort
    end

    @shadow_map_fb.render do
      scale 2.0 / @size, 1 do
        @distortion_fb.draw 0, 0, 0, shader: @reduction
      end
    end

    @shadows_fb.render do
      @shadow_casters_fb.draw 0, 0, 0, shader: @draw_shadows
    end

    @blurred_fb.render do
      @shadows_fb.draw 0, 0, 0, shader: @blur
    end

    @window_shadows.render do |buffer|
      buffer.clear color: Gosu::Color::BLACK
      @blurred_fb.draw 0, 0, 0
    end
  end

  def needs_cursor?
    true
  end

  def button_down(id)
    case id
      when Gosu::KbEscape
        close
      when Gosu::KbSpace
        place_shadow_casters
    end
  end

  def draw
    @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)
    flush # seem to need to flush to get :multiply to work!

    @window_shadows.draw 0, 0, 0, blend: :multiply
    @shadow_casters_fb.draw 0, 0, 0

    pixel.draw_rot @size / 2, @size / 2, 0, 0, 0.5, 0.5, 10, 10

    trace_color = Gosu::Color.rgba 255, 255, 255, 50
    draw_line 0, 0, trace_color, @size, @size, trace_color, 0
    draw_line 0, @size, trace_color, @size, 0, trace_color, 0

    # Drawing after the effect isn't processed, which is useful for GUI elements.
    @font.draw "FPS: #{Gosu::fps}", 0, 0, 0
  end
end

TestWindow.new.show