/*
 * module Ashton
 *
 * Ruby module extension for Gosu, implementing shaders and textures.
 *
 */

#include "ashton.h"

VALUE rb_mAshton;

void Init_ashton()
{
    rb_mAshton = rb_define_module("Ashton");

    srand((float)time(NULL));

    Init_Gosu();

    Init_Ashton_Texture(rb_mAshton);
    Init_Ashton_ParticleEmitter(rb_mAshton);
    Init_Ashton_Shader(rb_mAshton);
    Init_Ashton_PixelCache(rb_mAshton);
    //Init_Ashton_WindowBuffer(rb_mAshton);


    rb_define_singleton_method(rb_mAshton, "fast_sin", Ashton_fast_sin, 1);
    rb_define_singleton_method(rb_mAshton, "fast_cos", Ashton_fast_cos, 1);
    rb_define_method(rb_mAshton, "fast_sin", Ashton_fast_sin, 1);
    rb_define_method(rb_mAshton, "fast_cos", Ashton_fast_cos, 1);
}

VALUE Ashton_fast_sin(VALUE self, VALUE angle)
{
    return rb_float_new(fast_sin_deg(NUM2DBL(angle)));
}

VALUE Ashton_fast_cos(VALUE self, VALUE angle)
{
   return rb_float_new(fast_cos_deg(NUM2DBL(angle)));
}

