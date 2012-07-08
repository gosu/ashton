#version 110

uniform mat4 in_ModelView;
uniform mat4 in_ProjectionView;

attribute vec4 in_Vertex;
attribute vec2 in_TexCoord;
attribute vec4 in_Color;

uniform vec2 in_SpriteOffset;
uniform vec2 in_SpriteSize;

varying vec4 var_Color;
varying vec2 var_TexCoord;

void main()
{

  gl_Position = ftransform(); //vec4(in_Vertex.xy, 0.0, 1.0); //* (in_ModelView * in_Projection);
  var_Color = in_Color;
  var_TexCoord = in_SpriteOffset + (in_TexCoord * in_SpriteSize);
}