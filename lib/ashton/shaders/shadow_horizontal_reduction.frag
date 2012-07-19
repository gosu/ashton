#version 110

uniform sampler2D in_Texture; // Original texture.
uniform int in_TextureWidth; // Texture must be square, but can be any size divisible by 2.

varying vec2 var_TexCoord; // Pixel to process on this pass.

void main()
{
    float pixel_width = 1.0 / float(in_TextureWidth);
    int half_width = in_TextureWidth / 2;

    // Get the left-most pixel.
    gl_FragColor = texture2D(in_Texture, var_TexCoord);

    // Grab each pixel to the right in turn and min it with the previous one.
    for(int i = 1; i < half_width; i++)
    {
        vec2 color = texture2D(in_Texture, var_TexCoord + vec2(pixel_width * float(i), 0)).rg;

        gl_FragColor.rg = min(gl_FragColor.rg, color.rg);
    }
}