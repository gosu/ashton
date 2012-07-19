#version 110

const float MIN_ALPHA_TO_CAST_SHADOW = 0.3; // Ignore mostly transparent pixels.

uniform sampler2D in_Texture; // Texture containing shadow-casting shapes.

varying vec2 var_TexCoord; // Pixel to process on this pass.

void main()
{
    // Translate u and v into [-1 , 1] domain
    float u0 = var_TexCoord.x * 2.0 - 1.0;
    float v0 = (1.0 - var_TexCoord.y) * 2.0 - 1.0; // Inverted because Gosu Y-coordinate is "inverted".

    // Then, as u0 approaches 0 (the center), v should also approach 0
    v0 = v0 * abs(u0);

    // Convert back from [-1,1] domain to [0,1] domain
    v0 = (v0 + 1.0) / 2.0;

    v0 = 1.0 - v0;

    // We now have the coordinates for reading from the initial image
    vec2 newCoords = vec2(var_TexCoord.x, v0);

    // Read for both horizontal and vertical direction and store them in separate channels
    float horizontal = texture2D(in_Texture, newCoords).a;
    float distanceH = (horizontal > MIN_ALPHA_TO_CAST_SHADOW ? length(newCoords - 0.5) : 1.0);

    float vertical = texture2D(in_Texture, newCoords.yx).a;
    float distanceV = (vertical > MIN_ALPHA_TO_CAST_SHADOW ? length(newCoords - 0.5) : 1.0);

    gl_FragColor = vec4(distanceH, distanceV, 0.0, 1.0);
}