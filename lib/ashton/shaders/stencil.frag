#version 110

varying vec4 var_Color;
varying vec2 var_TexCoord0;
varying vec2 var_TexCoord1;

uniform sampler2D in_Texture;
uniform sampler2D in_Mask;
 
void main()
{
  vec4 texColor = texture2D(in_Texture, var_TexCoord0);
  vec4 maskColor = texture2D(in_Mask, var_TexCoord1);
  vec4 finalColor = vec4(texColor.r, texColor.g, texColor.b, texColor.a - maskColor.a);
  gl_FragColor = finalColor;
}