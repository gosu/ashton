/*
 * class Gosu::Color
 *
 *
 */


#ifndef GOSU_COLOR_H
#define GOSU_COLOR_H

#include <math.h>

#include "common.h"

void Init_Gosu_Color(VALUE module);

// Singleton methods
VALUE Gosu_Color_from_opengl(VALUE klass, VALUE array);

// Methods
VALUE Gosu_Color_to_opengl(VALUE self);
VALUE Gosu_Color_to_i(VALUE self);

#endif // GOSU_COLOR_H

