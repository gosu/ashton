#version 110

attribute vec2 in_TexCoord;

varying vec2 var_TexCoord;

void main()
{
  gl_Position = ftransform();
  var_TexCoord = in_TexCoord;
}