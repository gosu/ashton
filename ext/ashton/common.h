#ifndef COMMON_H
#define COMMON_H

#include <ruby.h>
#include <stdbool.h>

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

#define SYMBOL(STR) ID2SYM(rb_intern(STR))

// Global variables for each Gosu module/class.
extern VALUE rb_mGosu;
extern VALUE rb_cColor;
extern VALUE rb_cFont;
extern VALUE rb_cImage;
extern VALUE rb_cWindow;

// Global variables for each Ashton module/class.
extern VALUE rb_mAshton;
extern VALUE rb_cPixelCache;
extern VALUE rb_cShader;
extern VALUE rb_cTexture;

#endif // COMMON_H