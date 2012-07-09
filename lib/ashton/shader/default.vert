#version 110

attribute vec2 in_TexCoord;
attribute vec4 in_Color;

uniform vec2 in_SpriteOffset;
uniform vec2 in_SpriteSize;

varying vec4 var_Color;
varying vec2 var_TexCoord;

void main()
{

  gl_Position = ftransform();
  var_Color = in_Color;
  var_TexCoord = in_SpriteOffset + (in_TexCoord * in_SpriteSize);
}