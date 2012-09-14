/*
 * module Ashton
 *
 * Ruby module extension for Gosu, implementing shaders and textures.
 *
 */


#ifndef ASHTON_H
#define ASHTON_H

#include <ruby.h>
#include <time.h>

#include "common.h"
#include "fast_math.h"

#include "gosu.h"

#include "texture.h"
#include "particle_emitter.h"
#include "pixel_cache.h"
#include "shader.h"
//#include "window_buffer.h"

void Init_ashton();
VALUE Ashton_fast_sin(VALUE self, VALUE angle);
VALUE Ashton_fast_cos(VALUE self, VALUE angle);

#endif // ASHTON_H

