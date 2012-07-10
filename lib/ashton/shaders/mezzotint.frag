#version 110

#include <rand>

uniform sampler2D in_Texture;

uniform int in_T;

varying vec2 var_TexCoord;

void main() {
	vec4 color;

    color = texture2D(in_Texture, var_TexCoord);

	vec3 mezzo = vec3(0.0);
	if(rand(var_TexCoord + float(in_T)/640.0) <= color.r) { mezzo.r = 1.0; }
	if(rand(var_TexCoord + float(in_T)/640.0) <= color.g) { mezzo.g = 1.0; }
	if(rand(var_TexCoord + float(in_T)/640.0) <= color.b) { mezzo.b = 1.0; }
		
    gl_FragColor.rgb = mezzo;
}
