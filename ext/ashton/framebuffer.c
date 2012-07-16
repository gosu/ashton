#include "framebuffer.h"

void Init_Ashton_Framebuffer(VALUE module)
{
    VALUE rb_cFramebuffer = rb_define_class_under(module, "Framebuffer", rb_cObject);
}