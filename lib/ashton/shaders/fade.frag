#version 110

// This is sort of a pointless shader, since the same effect can be
// had drawing in :multiply mode.

uniform sampler2D in_Texture;

uniform float in_Fade; // 1.0 => no effect, 0.0 => becomes invisible.

varying vec2 var_TexCoord;

void main() {
  gl_FragColor = texture2D(in_Texture, var_TexCoord) * in_Fade;
}
