#version 110

// http://www.gamerendering.com/2008/12/20/radial-blur-filter/

uniform sampler2D in_Texture; // Texture to manipulate.
uniform int in_WindowWidth;
uniform int in_WindowHeight;

uniform float in_Spacing; // good value is 1.0;
uniform float in_Strength; // good value is 2.2;

varying vec2 var_TexCoord;

void main(void)
{
    // some sample positions. GLSL 1.10 is painfully dumb with arrays :)
    float samples[10];
    samples[0] = -0.08;
    samples[1] = -0.05;
    samples[2] = -0.03;
    samples[3] = -0.02;
    samples[4] = -0.01;
    samples[5] =  0.01;
    samples[6] =  0.02;
    samples[7] =  0.03;
    samples[8] =  0.05;
    samples[9] =  0.08;

    // 0.5,0.5 is the center of the screen
    // so substracting uv from it will result in
    // a vector pointing to the middle of the screen
    vec2 dir = 0.5 - var_TexCoord;

    // calculate the distance to the center of the screen
    float dist = sqrt(dir.x * dir.x + dir.y * dir.y);

    // normalize the direction (reuse the distance)
    dir /= dist;

    // this is the original colour of this fragment
    // using only this would result in a non-blurred version
    vec4 color = texture2D(in_Texture, var_TexCoord);

    vec4 sum = color;

    // take 10 additional blur samples in the direction towards
    // the center of the screen
    for (int i = 0; i < 10; i++)
    {
        sum += texture2D(in_Texture, var_TexCoord + dir * samples[i] * in_Spacing);
    }

    // we have taken eleven samples
    sum *= 1.0/11.0;

    // weighten the blur effect with the distance to the
    // center of the screen ( further out is blurred more)
    float t = dist * in_Strength;
    t = clamp(t, 0.0, 1.0); //0 &lt;= t &lt;= 1

    // Blend the original color with the averaged pixels
    gl_FragColor = mix(color, sum, t);
}