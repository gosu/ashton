#version 110

uniform int in_TextureWidth; // Width and height of the texture, so we know how big pixels are.

varying vec2 var_TexCoord;

void main()
{
    gl_Position = ftransform();

    // Offset the position by one pixel to correctly align texels to pixels
    float pixel_width = 1.0 / float(in_TextureWidth);
    var_TexCoord = gl_MultiTexCoord0.xy + 1.0 / vec2(-in_TextureWidth, in_TextureWidth);
}