#version 110

#include <rand>

// Rather poor quality noise generation, but better than nothing and sort of looks like TV static a bit.

uniform sampler2D in_Texture;

uniform int in_WindowWidth; // Not used.
uniform int in_WindowHeight; // Not used.

uniform float in_Intensity;
uniform float in_T;

varying vec2 var_TexCoord;

void main() {
	vec4 color = texture2D(in_Texture, var_TexCoord);
	
	vec4 influence = min(color, 1.0 - color);
	
	float noise = 1.0 - 2.0 * rand(var_TexCoord + float(in_T));
	
    gl_FragColor = color + in_Intensity * influence * noise;
}
