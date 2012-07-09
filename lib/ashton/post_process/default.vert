#version 110

varying vec2 var_TexCoord;

void main()
{
  gl_Position = ftransform();
  var_TexCoord = gl_MultiTexCoord0.xy;
}