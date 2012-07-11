#version 110

// Bloom filter
// http://myheroics.wordpress.com/2008/09/04/glsl-bloom-shader/
//
// Spooner: Added uniforms for setting bloom intensity.

uniform sampler2D in_Texture; // Original in_Texture.
varying vec2 var_TexCoord; // Pixel to process on this pass

uniform float in_GlareSize; // 0.004 is good
uniform float in_Power; // 0.25 is good

void main()
{
    vec4 sum = vec4(0);
    int i, j;

    for(i = -4; i < 4; i++)
    {
        for (j = -3; j < 3; j++)
        {
            sum += texture2D(in_Texture, var_TexCoord + vec2(j, i) * in_GlareSize) * in_Power;
        }
    }

    vec4 base_color = texture2D(in_Texture, var_TexCoord);

    if (base_color.r < 0.3)
    {
        gl_FragColor = sum * sum * 0.012 + base_color;
    }
    else if(base_color.r < 0.5)
    {
        gl_FragColor = sum * sum * 0.009 + base_color;
    }
    else
    {
        gl_FragColor = sum * sum * 0.0075 + base_color;
    }
}