/*
 * module Ashton
 *
 * Ruby module extension for Gosu, implementing shaders and framebuffers.
 *
 */

#include "ashton.h"

void Init_ashton()
{
    m_ashton = rb_define_module("Ashton");

    VALUE rb_cFramebuffer = rb_define_class_under(m_ashton, "FrameBuffer", rb_cObject);
    VALUE rb_cShader = rb_define_class_under(m_ashton, "Shader", rb_cObject);
    //VALUE rb_cWindowBuffer = rb_define_class_under(m_ashton, "WindowBuffer", rb_cFramebuffer);

    srand(time(NULL));

    //Init_Gosu();
    Init_Ashton_ParticleEmitter(m_ashton);
}

