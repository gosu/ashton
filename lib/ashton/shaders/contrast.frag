#version 110

uniform sampler2D in_Texture;
uniform float in_Contrast;

varying vec2 var_TexCoord;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
  
  color = (color - 0.5) * in_Contrast + 0.5;
  
  gl_FragColor.rgb = color.rgb;
  gl_FragColor.a = 1.0;
}
