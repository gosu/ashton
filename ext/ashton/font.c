#include "font.h"

void Init_Gosu_Font(VALUE module)
{
    rb_cFont = rb_define_class_under(module, "Font", rb_cObject);
}