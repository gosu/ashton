#include "fast_math.h"

//
void initialize_fast_math()
{
    for(int i = 0; i < NUM_LOOKUP_VALUES; i++)
    {
        float angle = DEGREES_TO_RADIANS((float)i / LOOKUPS_PER_DEGREE);
        sin_lookup[i] = sin(angle + LOOKUP_PRECISION);
    }

    // Ensure the cardinal directions are 100% accurate.
    for (int i = 0; i < 360; i += 90)
    {
        sin_lookup[i * LOOKUPS_PER_DEGREE] = sin(i * M_PI / 180.0);
    }
}
