#include "color.h"

void Init_Gosu_Color(VALUE module)
{
    VALUE rb_cColor = rb_define_class_under(module, "Color", rb_cObject);
}