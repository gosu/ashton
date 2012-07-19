#version 110

// Based on Catalin Zima's shader based dynamic shadows system.
// http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/

uniform sampler2D in_Texture; // Shadow map texture.

uniform int in_TextureWidth;

varying vec2 var_TexCoord; // Pixel to process on this pass.

float GetShadowDistanceH()
{
		float u = var_TexCoord.x;
		float v = var_TexCoord.y;

		u = abs(u - 0.5) * 2.0;
		v = v * 2.0 - 1.0;
		float v0 = v / u;
		v0 = (v0 + 1.0) / 2.0;
		
		vec2 newCoords = vec2(var_TexCoord.x, v0);
		
		//horizontal info was stored in the Red component
		return texture2D(in_Texture, newCoords).r;
}

float GetShadowDistanceV()
{
		float u = var_TexCoord.y;
		float v = var_TexCoord.x;
		
		u = abs(u - 0.5) * 2.0;
		v = v * 2.0 - 1.0;
		float v0 = v / u;
		v0 = (v0 + 1.0) / 2.0;
		
		vec2 newCoords = vec2(var_TexCoord.y, v0);
		
		//vertical info was stored in the Green component
		return texture2D(in_Texture, newCoords).g;
}

void main()
{
	  // distance of this pixel from the center
	  float distance = length(var_TexCoord - 0.5);
	  distance *= float(in_TextureWidth);
	  
	  //apply a 2-pixel bias
	  distance -= 2.0;

	  //distance stored in the shadow map
	  float shadowMapDistance;

	  //coords in [-1,1]
	  float nY = 2.0 * (var_TexCoord.y - 0.5);
	  float nX = 2.0 * (var_TexCoord.x - 0.5);

	  //we use these to determine which quadrant we are in
	  if(abs(nY) < abs(nX))
	  {
		shadowMapDistance = GetShadowDistanceH();
	  }
	  else
	  {
	    shadowMapDistance = GetShadowDistanceV();
	  }

	  shadowMapDistance *= float(in_TextureWidth);

	  //if distance to this pixel is lower than distance from shadowMap,
	  //then we are not in shadow
	  float light = (distance < shadowMapDistance) ? 1.0 : 0.0;

	  gl_FragColor = vec4(vec2(light), length(var_TexCoord - 0.5), 1.0);
}