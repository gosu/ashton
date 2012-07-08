#version 110

uniform sampler2D in_Texture;
uniform float column_width;

varying vec2 var_TexCoord;

void main(void)
{
    vec3 color = texture2D(in_Texture, var_TexCoord).rgb;
	
	float column_index = var_TexCoord.x / column_width;
	int ci = int(column_index);
	while(ci >= 3) { ci -= 3; } // % doesn't seem to work
	
	gl_FragColor.rgb = color * 0.125;
	if(ci == 0) { gl_FragColor.r = color.r; }
 	if(ci == 1) { gl_FragColor.g = color.g; }
	if(ci == 2) { gl_FragColor.b = color.b; }
}
