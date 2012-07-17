#version 110

const float ALPHA_THRESHOLD = 0.5;

const vec2 TextureSize = vec2(1024.0, 1024.0); // Gosu-specific!
const vec2 PixelSize = 1.0 / TextureSize;

// Automatically set by Ray (actually passed from the vertex shader).
uniform sampler2D in_Texture; // Original texture.
//uniform int in_WindowWidth;
//uniform int in_WindowHeight;

uniform vec4 in_OutlineColor;
uniform float in_OutlineWidth; // In pixels.

varying vec2 var_TexCoord; // Pixel to process on this pass
varying vec4 var_Color;

void main()
{
    gl_FragColor = texture2D(in_Texture, var_TexCoord); // * var_Color;

    if(gl_FragColor.a < ALPHA_THRESHOLD)
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

                        // Simplified return, since GLSL 1.10 hates `return`.
                        i = 2;
                        j = 2;
                    }
                }
            }
        }
    }
}