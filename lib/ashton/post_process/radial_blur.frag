#version 110

uniform sampler2D in_Texture; // Texture to manipulate.
uniform int in_WindowWidth;
uniform int in_WindowHeight;

uniform float in_BlurFactor;
uniform float in_BrightFactor;
uniform float in_OriginX;
uniform float in_OriginY;
uniform int in_Passes; // Number of passes to make (more is slower)

varying vec2 var_TexCoord; // Coordinate coming from the default vertex shader.

void main(void)
{
	vec2 Origin = vec2(in_OriginX, 1.0 - in_OriginY);

	vec2 TexCoord = vec2(var_TexCoord);

	vec4 SumColor = vec4(0.0, 0.0, 0.0, 0.0);
	TexCoord += vec2(1.0 / float(in_WindowWidth), 1.0 / float(in_WindowHeight)) * 0.5 - Origin;

	for (int i = 0; i < in_Passes; i++)
	{
		float Scale = 1.0 - in_BlurFactor * (float(i) / float(in_Passes - 1));
		SumColor += texture2D(in_Texture, TexCoord * Scale + Origin);
	}

	gl_FragColor = SumColor / float(in_Passes) * in_BrightFactor;
}
