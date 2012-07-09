#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

uniform float in_Center;
uniform float in_WaveWidth;
uniform float in_Time;
uniform float in_Ratio;
uniform float in_Refraction;

uniform int in_WindowWidth;
uniform int in_WindowHeight;

const float PI = 3.14159;

void main()
{
    vec2 source_coords = var_TexCoord;
    vec3 color = texture2D(in_Texture, source_coords).rgb;

    float x = in_X / float(in_WindowHeight);
    float y = 1.0 - in_Y / float(in_WindowHeight);
    vec2 rel = source_coords - vec2(x, y);
    rel.x *= in_Ratio;

    float dist = sqrt(rel.x * rel.x + rel.y * rel.y);

    if(dist >= in_Min && dist <= in_Max)
    {
        float inner = (dist - in_Min) / (in_Max - in_Min);
        float depth = 0.5 + 0.5 * cos((inner + 0.5) * 2.0 * PI);

        source_coords -= depth * rel / dist * in_Refraction;
        color = texture2D(in_Texture, source_coords).rgb;
    }
    
    gl_FragColor.rgb = color;
}
