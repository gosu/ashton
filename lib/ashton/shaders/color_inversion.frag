#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

void main()
{
  vec4 color = texture2D(in_Texture, var_TexCoord);
  gl_FragColor = vec4(vec3(1.0) - color.rgb, color.a);
}