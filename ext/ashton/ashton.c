/*
 * module Ashton
 *
 * Ruby module extension for Gosu, implementing shaders and framebuffers.
 *
 */

#include "ashton.h"

void Init_ashton()
{
    rb_mAshton = rb_define_module("Ashton");

    srand(time(NULL));

    Init_Gosu();

    Init_Ashton_Framebuffer(rb_mAshton);
    Init_Ashton_ParticleEmitter(rb_mAshton);
    Init_Ashton_Shader(rb_mAshton);
    //Init_Ashton_WindowBuffer(rb_mAshton);
}

