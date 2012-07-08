#version 110

uniform sampler2D in_Texture;

uniform float fade; # 1.0 => normal 0.0 => invisible.

varying vec2 var_TexCoord;

void main(void) {
    gl_FragColor = texture2D(in_Texture, var_TexCoord) * fade;
}
