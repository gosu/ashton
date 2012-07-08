#version 110

uniform sampler2D in_Texture;

uniform float intensity;
uniform int t;

varying vec2 var_TexCoord;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main(void) {
	vec4 color = texture2D(in_Texture, var_TexCoord.xy);
	
	vec4 influence = min(color, 1.0 - color);
	
	float noise = 1.0 - 2.0*rand(var_TexCoord + float(t)/640.0);
	
    gl_FragColor = color + intensity*influence*noise;
}
