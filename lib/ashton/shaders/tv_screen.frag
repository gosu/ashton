#version 110

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

    int c = int(mod(column_index, 3.0));
    if(c == 0) { gl_FragColor.r = color.r; }
    else if(c == 1) { gl_FragColor.g = color.g; }
    else if(c == 2) { gl_FragColor.b = color.b; }
}
