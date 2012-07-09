#version 110

attribute vec4 in_Color;

varying vec4 var_Color;
varying vec2 var_TexCoord;

void main()
{

  gl_Position = ftransform();
  var_Color = in_Color;
  var_TexCoord = gl_MultiTexCoord0.xy;
}