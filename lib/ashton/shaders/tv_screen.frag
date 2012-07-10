#version 110
#extension GL_EXT_gpu_shader4 : enable

uniform sampler2D in_Texture;

uniform float in_ColumnWidth; // In pixels.
uniform int in_WindowWidth;
uniform int in_WindowHeight; // Not used in this shader.

varying vec2 var_TexCoord;

void main()
{
    vec3 color = texture2D(in_Texture, var_TexCoord).rgb;

	gl_FragColor = vec4(color * 0.25, 1.0);

	float column_index = var_TexCoord.x * float(in_WindowWidth) / in_ColumnWidth;

	switch(int(column_index) % 3)
    {
      case 0:
        gl_FragColor.r = color.r;
        break;
      case 1:
        gl_FragColor.g = color.g;
        break;
      case 2:
        gl_FragColor.b = color.b;
        break;
    }
}
