#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

uniform float x, y, min, max, ratio, refraction;

void main(void)
{
    vec3 color = texture2D(in_Texture, var_TexCoord).rgb;
    
    vec2 rel = var_TexCoord - vec2(x, 1.0 - y);
    rel.x *= ratio;

    float dist = sqrt(rel.x*rel.x + rel.y*rel.y);
    float inner = (dist - min) / (max - min);

    if(dist >= min && dist <= max)
    {
        float depth = 0.5 + 0.5 * cos((inner + 0.5) * 2.0 * 3.14159);
        source_coords -= depth * rel / dist * refraction;
        color = texture2D(in_Texture, var_TexCoord).rgb;
    }
    
    gl_FragColor.rgb = color;
}
