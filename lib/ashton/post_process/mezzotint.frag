#version 110

uniform sampler2D in_Texture;

uniform int t;

varying vec2 var_TexCoord;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
	vec4 color;

    color = texture2D(in_Texture, var_TexCoord);

	vec3 mezzo = vec3(0.0);
	if(rand(var_TexCoord + float(t)/640.0) <= color.r) { mezzo.r = 1.0; }
	if(rand(var_TexCoord + float(t)/640.0) <= color.g) { mezzo.g = 1.0; }
	if(rand(var_TexCoord + float(t)/640.0) <= color.b) { mezzo.b = 1.0; }
		
    gl_FragColor.rgb = mezzo;
}
