#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

void main()
{
  vec4 Sepia1 = vec4( 0.2, 0.05, 0.0, 1.0 );    
  vec4 Sepia2 = vec4( 1.0, 0.9, 0.5, 1.0 );
 
  vec4 Color = texture2D(in_Texture, vec2(var_TexCoord));

  if(Color.a == 0.0)
  {
    gl_FragColor = Color;
  }
  else
  {
    float SepiaMix = dot(vec3(0.3, 0.59, 0.11), vec3(Color));
    Color = mix(Color, vec4(SepiaMix), vec4(0.5));
    vec4 Sepia = mix(Sepia1, Sepia2, SepiaMix);

    gl_FragColor = mix(Color, Sepia, 1.0);
  }
}
