/*
 * module Ashton
 *
 * Ruby module extension for Gosu, implementing shaders and framebuffers.
 *
 */


#ifndef ASHTON_H
#define ASHTON_H

#include <ruby.h>
#include <time.h>

static VALUE rb_mAshton;

#include "common.h"


#include "gosu.h"

#include "framebuffer.h"
#include "particle_emitter.h"
#include "pixel_cache.h"
#include "shader.h"
//#include "window_buffer.h"

void Init_ashton();

#endif // ASHTON_H

