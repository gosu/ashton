#include "window.h"

VALUE rb_cWindow;

void Init_Gosu_Window(VALUE module)
{
    rb_cWindow = rb_define_class_under(module, "Window", rb_cObject);
}