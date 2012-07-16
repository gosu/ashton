#include "window.h"

void Init_Gosu_Window(VALUE module)
{
    VALUE rb_cWindow = rb_define_class_under(module, "Window", rb_cObject);
}