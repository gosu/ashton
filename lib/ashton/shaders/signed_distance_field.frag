#version 110

// Calculates a signed distance field, based on how far any pixel is from an opaque pixel.
// In each pixel, the signed value is actually r/g/b - 128
//    if r/g/b > 0 => distance from an opaque pixel.
//    if r/g/b <= 0 => distance from an opaque pixel that is adjacent to a transparent pixel.

uniform sampler2D in_Texture; // Original texture.

uniform vec2 in_TextureSize; // Width and height of the texture, so we know how big pixels are.
uniform int in_StepSize; // Distance to check each time (larger steps will be faster, but less accurate).
uniform int in_MaxDistance; // Maximum distance to search out to. Cannot be more than 127!

varying vec2 var_TexCoord; // Pixel to process on this pass.

const float NUM_SPOKES = 36.0; // Number of radiating lines to check in.
const float ANGULAR_STEP = 360.0 / NUM_SPOKES;

const int ZERO_VALUE = 128; // Color channel containing 0 => -128, 128 => 0, 255 => +127

// Returns true an alpha value is found at this distance (any direction).
bool find_alpha_at_distance(in vec2 center, in vec2 distance, in float alpha)
{
    bool found = false;

    for(float angle = 0.0; angle < 360.0; angle += ANGULAR_STEP)
    {
        vec2 position = center + distance * vec2(cos(angle), sin(angle));

        if(texture2D(in_Texture, position).a == alpha)
        {
           found = true;
           angle = 361.0;
        }
    }

    return found;
}

void main()
{
    vec2 pixel_size = 1.0 / in_TextureSize;

    int distance;

    if(texture2D(in_Texture, var_TexCoord).a == 0.0)
    {
        // Texel is transparent, search for nearest opaque.
        distance = ZERO_VALUE + 1;
        for(int i = in_StepSize; i < in_MaxDistance; i += in_StepSize)
        {
            if(find_alpha_at_distance(var_TexCoord, float(i) * pixel_size, 1.0))
            {
                i = in_MaxDistance + 1; // BREAK!
            }
            else
            {
                distance = ZERO_VALUE + 1 + i;
            }
        }
    }
    else
    {
        // Texel is opaque, search for nearest transparent.
        distance = ZERO_VALUE;
        for(int i = in_StepSize; i <= in_MaxDistance; i += in_StepSize)
        {
            if(find_alpha_at_distance(var_TexCoord, float(i) * pixel_size, 0.0))
            {
                i = in_MaxDistance + 1; // BREAK!
            }
            else
            {
                distance = ZERO_VALUE - i;
            }
        }
    }

    gl_FragColor =  vec4(vec3(float(distance) / 255.0), 1.0);
}