#version 110

// Based on Catalin Zima's shader based dynamic shadows system.
// http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/

uniform sampler2D in_Texture; // Shadow map texture.

uniform int in_TextureWidth;

varying vec2 var_TexCoord; // Pixel to process on this pass.

// coord x and y should be inverted when reading vertical distortion.
vec4 GetShadowDistances(in vec2 coord)
{
		float u = coord.x;
		float v = coord.y;
		
		u = abs(u - 0.5) * 2.0;
		v = v * 2.0 - 1.0;
		float v0 = v / u;
		v0 = (v0 + 1.0) / 2.0;
		
		vec2 newCoords = vec2(coord.x, v0);

		return texture2D(in_Texture, newCoords);
}

void main()
{
	  // Distance of this pixel from the center.
	  float distance = length(var_TexCoord - 0.5);

	  // Apply a 2-pixel bias, so we can see the edge of shadow-caster.
	  distance -= 2.0 / float(in_TextureWidth);

	  //distance stored in the shadow map
	  float shadowMapDistance;

	  // Coords in [-1,1]
	  float nY = 2.0 * (var_TexCoord.y - 0.5);
	  float nX = 2.0 * (var_TexCoord.x - 0.5);

	  // We use these to determine which quadrant we are in.
	  if(abs(nY) < abs(nX))
	  {
	    // Horizontal distance was stored in the Red component.
		shadowMapDistance = GetShadowDistances(var_TexCoord).r;
	  }
	  else
	  {
	    // Vertical distance was stored in the Green component.
	    shadowMapDistance = GetShadowDistances(var_TexCoord.yx).g;
	  }

	  // If distance to this pixel is lower than distance from shadowMap,
	  // then we are not in shadow.
	  float light = (distance < shadowMapDistance) ? 1.0 : 0.0;

	  gl_FragColor = vec4(vec2(light), length(var_TexCoord - 0.5), 1.0);
}