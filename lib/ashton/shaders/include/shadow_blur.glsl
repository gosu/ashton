const vec2 oneZero = vec2(1.0, 0.0);
const vec2 zeroOne = vec2(0.0, 1.0);
const float minBlur = 0.0;
const float maxBlur = 5.0;
const int blurSamples = 13;

float saturate(in float x)
{
    return min(max(x, 0.0), 1.0);
}