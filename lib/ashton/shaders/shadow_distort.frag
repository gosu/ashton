#version 110

uniform sampler2D in_Texture; // Original texture.

varying vec2 var_TexCoord; // Pixel to process on this pass.

void main()
{
    //translate u and v into [-1 , 1] domain
    float u0 = var_TexCoord.x * 2.0 - 1.0;
    float v0 = var_TexCoord.y * 2.0 - 1.0;

    //then, as u0 approaches 0 (the center), v should also approach 0
    v0 = v0 * abs(u0);

    //convert back from [-1,1] domain to [0,1] domain
    v0 = (v0 + 1.0) / 2.0;

    v0 = 1.0 - v0;

    //we now have the coordinates for reading from the initial image
    vec2 newCoords = vec2(var_TexCoord.x, v0);

    //read for both horizontal and vertical direction and store them in separate channels
    //read for both horizontal and vertical direction and store them in separate channels
    float horizontal = texture2D(in_Texture, newCoords).a;
    float distanceH = (horizontal > 0.3 ? length(newCoords - 0.5) : 1.0);

    float vertical = texture2D(in_Texture, newCoords.yx).a;
    float distanceV = (vertical > 0.3 ? length(newCoords - 0.5) : 1.0);

    gl_FragColor = vec4(distanceH, distanceV, 0.0, 1.0);
}