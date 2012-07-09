#version 110

#define KERNEL_SIZE 9

uniform int in_WindowWidth;
uniform int in_WindowHeight;

uniform sampler2D in_Texture;
uniform int in_PixelSize;

varying vec2 var_TexCoord;

vec2 texCoords[KERNEL_SIZE];

void main(void)
{
   vec4 avgColor;
   vec2 texCoordsStep = 1.0 /
            (vec2(float(in_WindowWidth), float(in_WindowHeight))/float(in_PixelSize));
   vec2 pixelBin = floor(var_TexCoord / texCoordsStep);
   vec2 inPixelStep = texCoordsStep / 3.0;
   vec2 inPixelHalfStep = inPixelStep / 2.0;


   texCoords[0] = vec2(inPixelHalfStep.x, inPixelStep.y*2.0 + inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[1] = vec2(inPixelStep.x + inPixelHalfStep.x, inPixelStep.y*2.0 + inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[2] = vec2(inPixelStep.x*2.0 + inPixelHalfStep.x, inPixelStep.y*2.0 + inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[3] = vec2(inPixelHalfStep.x, inPixelStep.y + inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[4] = vec2(inPixelStep.x + inPixelHalfStep.x, inPixelStep.y + inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[5] = vec2(inPixelStep.x*2.0 + inPixelHalfStep.x, inPixelStep.y + inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[6] = vec2(inPixelHalfStep.x, inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[7] = vec2(inPixelStep.x + inPixelHalfStep.x, inPixelHalfStep.y) + pixelBin * texCoordsStep;
   texCoords[8] = vec2(inPixelStep.x*2.0 + inPixelHalfStep.x, inPixelHalfStep.y) + pixelBin * texCoordsStep;

   avgColor = texture2D(in_Texture, texCoords[0]) +
              texture2D(in_Texture, texCoords[1]) +
              texture2D(in_Texture, texCoords[2]) +
              texture2D(in_Texture, texCoords[3]) +
              texture2D(in_Texture, texCoords[4]) +
              texture2D(in_Texture, texCoords[5]) +
              texture2D(in_Texture, texCoords[6]) +
              texture2D(in_Texture, texCoords[7]) +
              texture2D(in_Texture, texCoords[8]);

   avgColor /= float(KERNEL_SIZE);

   gl_FragColor = avgColor;
}
