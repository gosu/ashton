#version 110

#define ALPHA_THRESHOLD 0.7
#define NUM_ADJACENT 8

const ivec2 TextureSize = ivec2(1024, 1024); // Gosu-specific!

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
//uniform int in_WindowWidth;
//uniform int in_WindowHeight;

uniform vec4 in_OutlineColor;
uniform float in_OutlineWidth; // In pixels.

varying vec2 var_TexCoord; // Pixel to process on this pass

void main()
{
    vec2 PixelSize = 1.0 / vec2(TextureSize.xy);
    vec4 color = texture2D(in_Texture, var_TexCoord);

    if(color.a < ALPHA_THRESHOLD)
    {
        for(int i = -1; i < 2; i++)
        {
            for(int j = -1; j < 2; j++)
            {
                if(i != 0 && j != 0)
                {
                    // Get the color of the adjacent pixel.
                    vec2 pos = var_TexCoord + vec2(i, j) * PixelSize * in_OutlineWidth;
                    if(texture2D(in_Texture, pos).a > ALPHA_THRESHOLD)
                    {
                        gl_FragColor = in_OutlineColor;
                        return;
                    }
                }
            }
        }

        gl_FragColor = vec4(0.0); // If none adjacent.
    }
    else
    {
    gl_FragColor = color;
    }
}