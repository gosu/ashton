#version 110

// Based on Catalin Zima's shader based dynamic shadows system.
// http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/

// Distort the input (square) texture into sight-lines, then reduce horizontally into a 2-pixel wide shadow-map texture.

const float MIN_ALPHA_TO_CAST_SHADOW = 0.3; // Ignore mostly transparent pixels.

uniform sampler2D in_Texture; // Texture containing shadow-casting shapes.
uniform int in_TextureWidth; // Texture must be square, but can be any size divisible by 2.

varying vec2 var_TexCoord; // Pixel to process on this pass.

vec4 distort(in vec2 coord)
{
    // Translate u and v into [-1 , 1] domain
    float u0 = coord.x * 2.0 - 1.0;
    float v0 = (1.0 - coord.y) * 2.0 - 1.0; // Inverted because Gosu Y-coordinate is "inverted".

    // Then, as u0 approaches 0 (the center), v should also approach 0
    v0 = v0 * abs(u0);

    // Convert back from [-1,1] domain to [0,1] domain
    v0 = (v0 + 1.0) / 2.0;

    v0 = 1.0 - v0;

    // We now have the coordinates for reading from the initial image
    vec2 newCoords = vec2(coord.x, v0);

    // Read for both horizontal and vertical direction and store them in separate channels
    float horizontal = texture2D(in_Texture, newCoords).a;
    float distanceH = (horizontal > MIN_ALPHA_TO_CAST_SHADOW ? length(newCoords - 0.5) : 1.0);

    float vertical = texture2D(in_Texture, newCoords.yx).a;
    float distanceV = (vertical > MIN_ALPHA_TO_CAST_SHADOW ? length(newCoords - 0.5) : 1.0);

    return vec4(distanceH, distanceV, 0.0, 1.0);
}

void main()
{
    float pixel_width = 1.0 / float(in_TextureWidth);
    int half_width = in_TextureWidth / 2;

    // Get the left-most pixel.
    gl_FragColor = distort(var_TexCoord);

    // Grab each pixel to the right in turn and min it with the previous one.
    for(int i = 1; i < half_width; i++)
    {
        vec2 color = distort(var_TexCoord + vec2(pixel_width * float(i), 0)).rg;

        gl_FragColor.rg = min(gl_FragColor.rg, color.rg);
    }
}