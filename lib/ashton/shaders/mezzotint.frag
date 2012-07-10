#version 110

#include <rand>

uniform sampler2D in_Texture;
uniform int in_WindowWidth;

uniform int in_T;

varying vec2 var_TexCoord;

void main() {
	vec4 color = texture2D(in_Texture, var_TexCoord);
	vec3 mezzo = vec3(0.0);
	float width = float(in_WindowWidth);

	if(rand(var_TexCoord + float(in_T) / width) <= color.r) { mezzo.r = 1.0; }
	if(rand(var_TexCoord + float(in_T) / width) <= color.g) { mezzo.g = 1.0; }
	if(rand(var_TexCoord + float(in_T) / width) <= color.b) { mezzo.b = 1.0; }
		
    gl_FragColor.rgb = mezzo;
}
