#version 110

#include <shadow_blur>

uniform sampler2D in_Texture; // Original texture.
uniform int in_TextureWidth;

varying vec2 var_TexCoord; // Pixel to process on this pass.

void main()
{
    vec2 offsetAndWeight[blurSamples];

    offsetAndWeight[0] = vec2(-6.0, 0.002216);
    offsetAndWeight[1] = vec2(-5.0, 0.008764);
    offsetAndWeight[2] = vec2(-4.0, 0.026995);
    offsetAndWeight[3] = vec2(-3.0, 0.064759);
    offsetAndWeight[4] = vec2(-2.0, 0.120985);
    offsetAndWeight[5] = vec2(-1.0, 0.176033);
    offsetAndWeight[6] = vec2( 0.0, 0.199471);
    offsetAndWeight[7] = vec2( 1.0, 0.176033);
    offsetAndWeight[8] = vec2( 2.0, 0.120985);
    offsetAndWeight[9] = vec2( 3.0, 0.064759);
    offsetAndWeight[10] = vec2( 4.0, 0.026995);
    offsetAndWeight[11] = vec2( 5.0, 0.008764);
    offsetAndWeight[12] = vec2( 6.0, 0.002216);

    float sum = 0.0;
    float distance = texture2D(in_Texture, var_TexCoord).b;
    float width = float(in_TextureWidth);
    
    for (int i = 0; i < blurSamples; i++)
    {
        float offset = offsetAndWeight[i].x;
        float weight = offsetAndWeight[i].y;
        
        vec2 coord = var_TexCoord +
                     offset *
                     (mix(minBlur, maxBlur, distance) / width) *
                     oneZero;
        
        sum += texture2D(in_Texture, coord).r * weight;
    }
    
    gl_FragColor = vec4(sum, sum, distance, 1.0);
}