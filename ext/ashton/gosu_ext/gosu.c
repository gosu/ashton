/*
 * module Gosu being extended.
 *
 */

#include "gosu.h"

void Init_Gosu()
{
    VALUE jm_Module = rb_define_module("Gosu");

    VALUE rb_cColor = rb_define_class_under(jm_Module, "Color", rb_cObject);
    VALUE rb_cImage = rb_define_class_under(jm_Module, "Image", rb_cObject);
    VALUE rb_cWindow = rb_define_class_under(jm_Module, "Window", rb_cObject);
}

