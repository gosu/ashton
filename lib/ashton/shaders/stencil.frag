#version 110

varying vec4 var_Color;
varying vec2 var_TexCoord0;
varying vec2 var_TexCoord1;

uniform sampler2D in_Texture0;
uniform sampler2D in_Texture1;
 
void main()
{
  vec4 texColor = texture2D(in_Texture0, var_TexCoord0);
  vec4 maskColor = texture2D(in_Texture1, var_TexCoord1);
  gl_FragColor = vec4(texColor.r, texColor.g, texColor.b, texColor.a - maskColor.a);
}