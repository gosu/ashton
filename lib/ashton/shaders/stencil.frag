#version 110

// Use a stencil texture to selectively draw. Drawing of the image will occur
// where the stencil is transparent (or only where the stencil is opaque if
// inverted).
//
// Partial transparency in the stencil will allow the image to be drawn
// partially too.

varying vec4 var_Color;
varying vec2 var_TexCoord0; // The texture/image to draw.
varying vec2 var_TexCoord1; // The stencil (multitexture).

uniform sampler2D in_Texture0; // The texture/image to draw.
uniform sampler2D in_Texture1; // The stencil (multitexture).
uniform bool in_Inverted; // true to draw in opaque areas / false to draw in transparent areas.
 
void main()
{
  vec4 texColor = texture2D(in_Texture0, var_TexCoord0);
  vec4 maskColor = texture2D(in_Texture1, var_TexCoord1);

  // Only draw the texture where the stencil is transparent (unless inverted).
  float mask_alpha = in_Inverted ? (1.0 - maskColor.a) : maskColor.a;

  gl_FragColor = vec4(texColor.r, texColor.g, texColor.b, texColor.a - mask_alpha);
}