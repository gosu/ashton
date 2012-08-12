#version 110

attribute vec4 in_Color;

varying vec4 var_Color;
varying vec2 var_TexCoord0;
varying vec2 var_TexCoord1;

void main()
{
  gl_Position = ftransform();
  var_Color = in_Color;

  // Set the coordinates for TEXTURE0
  var_TexCoord0 = gl_MultiTexCoord0.xy;

  // Set the coordinates for TEXTURE1
  var_TexCoord1 = gl_MultiTexCoord1.xy;
}