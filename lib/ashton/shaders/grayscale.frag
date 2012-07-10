#version 110

uniform sampler2D in_Texture;

varying vec2 var_TexCoord;

const vec3 Ratio = vec3(0.299, 0.587, 0.114);

void main()
{
    vec4 color = texture2D(in_Texture, var_TexCoord);
    float gray = dot(color.rgb, Ratio);
    gl_FragColor = vec4(vec3(gray), color.a);
}
