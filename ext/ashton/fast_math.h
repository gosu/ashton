// Lookup table based sin/cos using degrees.
//
// MUST call initialize_fast_math() before using the fast_ functions.

#ifndef FAST_MATH_H
#define FAST_MATH_H

#include <math.h>
#include <stdio.h>

#define DEGREES_TO_RADIANS(ANGLE) ((ANGLE - 90) * (M_PI / 180.0f))

#define LOOKUPS_PER_DEGREE 10
#define NUM_LOOKUP_VALUES (360 * LOOKUPS_PER_DEGREE)
#define LOOKUP_PRECISION (1.0f / LOOKUPS_PER_DEGREE)

extern float sin_lookup[NUM_LOOKUP_VALUES];

void initialize_fast_math();

// sin implementation using lookup table, accepting degrees rather than radians.
float fast_sin_deg(float degrees);

// cos implementation using lookup table, accepting degrees rather than radians.
#define fast_cos_deg(degrees) fast_sin_deg((degrees) + 90.0f)

#endif // FAST_MATH_H