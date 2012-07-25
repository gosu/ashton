#ifndef COMMON_H
#define COMMON_H

#include <ruby.h>

#include "GLee.h"

typedef unsigned char uchar;
typedef unsigned int uint;
typedef unsigned long ulong;

// Colour based on integer values (0..255)
typedef struct _color_i
{
    uchar red, green, blue, alpha;
} Color_i;


// Colour based on float values (0.0..1.0)
typedef struct _color_f
{
    float red, green, blue, alpha;
} Color_f;

#endif // COMMON_H