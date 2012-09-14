/*
 * module Gosu being extended.
 *
 */

#include "gosu.h"

VALUE rb_mGosu;

void Init_Gosu()
{
    rb_mGosu = rb_define_module("Gosu");

    Init_Gosu_Color(rb_mGosu);
    Init_Gosu_Font(rb_mGosu);
    Init_Gosu_Image(rb_mGosu);
    Init_Gosu_Window(rb_mGosu);
}
