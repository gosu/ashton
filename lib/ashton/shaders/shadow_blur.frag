#version 110

// Based on Catalin Zima's shader based dynamic shadows system.
// http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/


const float minBlur = 0.0;
const float maxBlur = 5.0; // TODO: Make this a uniform?
const int blurSamples = 13;

uniform sampler2D in_Texture; // Original texture.
uniform int in_TextureWidth;

varying vec2 var_TexCoord; // Pixel to process on this pass.

void main()
{
    vec2 offsetAndWeight[blurSamples];

    offsetAndWeight[0] = vec2( 0.0, 0.199471);
    offsetAndWeight[1] = vec2( 1.0, 0.176033);
    offsetAndWeight[2] = vec2( 2.0, 0.120985);
    offsetAndWeight[3] = vec2( 3.0, 0.064759);
    offsetAndWeight[4] = vec2( 4.0, 0.026995);
    offsetAndWeight[5] = vec2( 5.0, 0.008764);
    offsetAndWeight[6] = vec2( 6.0, 0.002216);

    vec4 color = texture2D(in_Texture, var_TexCoord);
    float distance = color.b;
    float pixel_width = 1.0 / float(in_TextureWidth);

    // Take a reading from the center pixel once,
    // but multiply since it would be added twice in the loop.
    float sum = color.r * offsetAndWeight[0].y * 2.0;

    for (int i = 1; i < blurSamples; i++)
    {
        float offset = offsetAndWeight[i].x;
        float weight = offsetAndWeight[i].y;

        offset *= pixel_width * mix(minBlur, maxBlur, distance);

        // Take colour from above, below, left and right at once.
        float effect = texture2D(in_Texture, var_TexCoord + vec2( offset,     0.0)).r +
                       texture2D(in_Texture, var_TexCoord + vec2(-offset,     0.0)).r +
                       texture2D(in_Texture, var_TexCoord + vec2(    0.0,  offset)).r +
                       texture2D(in_Texture, var_TexCoord + vec2(    0.0, -offset)).r;

        sum += effect * weight;
    }

    // Halve the sum, since we have applied horizontal and vertical at once.
    sum *= 0.5;

    // Light is brighter at the center.
    float d = 2.0 * length(var_TexCoord - 0.5);
    float attenuation = clamp(1.0 - d, 0.0, 1.0);

    gl_FragColor = vec4(vec3(sum * attenuation), 1.0);
}