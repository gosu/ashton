#version 130

#define ALPHA_THRESHOLD 0.7
#define NUM_ADJACENT 8

const vec2 Offsets[NUM_ADJACENT] = vec2[NUM_ADJACENT](
    vec2(-1, -1),   vec2(0, -1),   vec2(1, -1),
    vec2(-1,  0),                  vec2(1,  0),
    vec2(-1,  1),   vec2(0,  1),   vec2(1,  1)
);

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
//uniform int in_WindowWidth;
//uniform int in_WindowHeight;

uniform vec4 in_OutlineColor;
uniform float in_OutlineWidth; // In pixels.

in vec2 var_TexCoord; // Pixel to process on this pass

void main()
{
  vec2 PixelSize = 1.0 / textureSize(in_Texture, 0);
  vec4 color = texture2D(in_Texture, var_TexCoord);

  if(color.a < ALPHA_THRESHOLD)
  {
    for(int i = 0; i < NUM_ADJACENT; i++)
    {
      vec4 AdjacentColor = texture2D(in_Texture,
          var_TexCoord + Offsets[i] * PixelSize * in_OutlineWidth);
      if(AdjacentColor.a > ALPHA_THRESHOLD)
      {
         gl_FragColor = in_OutlineColor;
         return;
      }
    }

    gl_FragColor = vec4(0.0); // If none adjacent.
  }
  else
  {
    gl_FragColor = color;
  }
}