#version 110

// Rather poor quality noise generation, but better than nothing and sort of looks like TV static a bit.

uniform sampler2D in_Texture;

uniform int in_WindowWidth; // Not used.
uniform int in_WindowHeight; // Not used.

uniform float in_Intensity;
uniform float in_T;

varying vec2 var_TexCoord;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
	vec4 color = texture2D(in_Texture, var_TexCoord);
	
	vec4 influence = min(color, 1.0 - color);
	
	float noise = 1.0 - 2.0 * rand(var_TexCoord + float(in_T));
	
    gl_FragColor = color + in_Intensity * influence * noise;
}
