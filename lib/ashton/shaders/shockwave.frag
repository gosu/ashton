#version 110

// http://empire-defense.crystalin.fr/blog/2d_shock_wave_texture_with_shader
// http://www.geeks3d.com/20091116/shader-library-2d-shockwave-post-processing-filter-glsl/

uniform sampler2D in_Texture; // 0
uniform vec2 in_Center; // Mouse position
uniform float in_Time; // effect elapsed time. Multiply this to affect speed.

// Amplitude?, Refraction?, Width?  e.g. 10.0, 0.8, 0.1
uniform vec3 in_ShockParams;

uniform int in_WindowWidth;
uniform int in_WindowHeight;

varying vec2 var_TexCoord;

void main()
{
  vec2 uv = var_TexCoord;
  vec2 texCoord = uv;
  float x = in_Center.x / float(in_WindowWidth);
  float y = (float(in_WindowHeight) - in_Center.y) / float(in_WindowHeight);
  float distance = distance(uv, vec2(x, y));

  if ( (distance <= (in_Time + in_ShockParams.z)) &&
       (distance >= (in_Time - in_ShockParams.z)) )
  {
    float diff = (distance - in_Time);
    float powDiff = 1.0 - pow(abs(diff * in_ShockParams.x),
                                in_ShockParams.y);
    float diffTime = diff  * powDiff;
    vec2 diffUV = normalize(uv - in_Center);
    texCoord = uv + (diffUV * diffTime);
  }

  gl_FragColor = texture2D(in_Texture, texCoord);
}
