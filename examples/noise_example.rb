# Use of GLSL shader in Gosu to post-process the entire screen.

begin
  require 'rubygems'
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require "ashton"

def media_path(file); File.expand_path "media/#{file}", File.dirname(__FILE__) end

class TestWindow < Gosu::Window
  NOISE_FRAGMENT =<<-END
#version 110

// Use 3D Simplex noise, even though the shader operates on a 2D
// texture, since then we can make the Z-coordinate act as time.
#include <noise3d>

uniform sampler2D in_Texture;

uniform float in_T;
uniform vec4 in_BlobColor;

varying vec2 var_TexCoord;

void main()
{
  gl_FragColor = texture2D(in_Texture, var_TexCoord);

  // First layer. faster, low intensity, small scale blobbing.
  // Use [x, y, t] to create a 2D noise that varies over time.
  vec3 position1 = vec3(var_TexCoord * 25.0, in_T * 1.6);

  // Gives range 0.75..1.25
  float brightness1 = snoise(position1) / 4.0 + 1.0;

  // Second layer - slow, high intensity, large-scale blobbing
  // This decides where the first layer will be "seen"
  // Use [x, y, t] to create a 2D noise that varies over time.
  vec3 position2 = vec3(var_TexCoord * 3.0, in_T * 0.16);

  // Gives range 0.3..1.3
  float brightness2 = snoise(position2) / 2.0 + 0.8;

  if(brightness2 > 0.8)
  {
    gl_FragColor.rgb += in_BlobColor.rgb;
    gl_FragColor.rgb *= brightness1 * brightness2;
  }
}
  END

  def initialize
    super 640, 480, false
    self.caption = "Post-processing with the simplex noise function - intelligent blob?"

    @noise = Ashton::Shader.new fragment: NOISE_FRAGMENT, uniforms: {
        blob_color: Gosu::Color.rgb(0, 40, 0),
    }

    @font = Gosu::Font.new self, Gosu::default_font_name, 40
    @background = Gosu::Image.new(self, media_path("Earth.png"), true)
    @start_time = Time.now

    update # Ensure the values are initially set.
  end

  def update
    @noise.t = Time.now - @start_time
  end

  def draw
    post_process @noise do
      @background.draw 0, 0, 0, width.fdiv(@background.width), height.fdiv(@background.height)

      @font.draw_rel "Hello world!", 350, 50, 0, 0.5, 0.5, 1, 1, Gosu::Color::GREEN
      @font.draw_rel "Goodbye world!", 400, 350, 0, 0.5, 0.5, 2, 2, Gosu::Color::BLUE
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