#version 110

attribute vec4 in_Vertex;
attribute vec2 in_TexCoord;
attribute vec4 in_Color;

varying vec2 var_TexCoord;

void main(void)
{
  gl_Position = vec4(in_Vertex.xy, 0.0, 1.0);
  var_TexCoord = in_TexCoord;
}