#include "color.h"

void Init_Gosu_Color(VALUE module)
{
    rb_cColor = rb_define_class_under(module, "Color", rb_cObject);

    rb_define_singleton_method(rb_cColor, "from_opengl", Gosu_Color_from_opengl, 1);

    rb_define_method(rb_cColor, "to_opengl", Gosu_Color_to_opengl, 0);
    rb_define_method(rb_cColor, "to_i", Gosu_Color_to_i, 0);
}

VALUE Gosu_Color_from_opengl(VALUE klass, VALUE array)
{
    VALUE red = INT2NUM(round(NUM2DBL(rb_ary_entry(array, 0)) * 255.0));
    VALUE green = INT2NUM(round(NUM2DBL(rb_ary_entry(array, 1)) * 255.0));
    VALUE blue = INT2NUM(round(NUM2DBL(rb_ary_entry(array, 2)) * 255.0));
    VALUE alpha = INT2NUM(round(NUM2DBL(rb_ary_entry(array, 3)) * 255.0));

    return rb_funcall(klass, rb_intern("rgba"), 4, red, green, blue, alpha);
}

VALUE Gosu_Color_to_opengl(VALUE self)
{
    VALUE array = rb_ary_new();

    rb_ary_push(array, rb_float_new(NUM2INT(rb_funcall(self, rb_intern("red"),   0)) / 255.0));
    rb_ary_push(array, rb_float_new(NUM2INT(rb_funcall(self, rb_intern("green"), 0)) / 255.0));
    rb_ary_push(array, rb_float_new(NUM2INT(rb_funcall(self, rb_intern("blue"),  0)) / 255.0));
    rb_ary_push(array, rb_float_new(NUM2INT(rb_funcall(self, rb_intern("alpha"), 0)) / 255.0));

    return array;
}

VALUE Gosu_Color_to_i(VALUE self)
{
   uint argb = (NUM2UINT(rb_funcall(self, rb_intern("alpha"), 0)) << 24) +
               (NUM2UINT(rb_funcall(self, rb_intern("red"),   0)) << 16) +
               (NUM2UINT(rb_funcall(self, rb_intern("green"), 0)) << 8) +
                NUM2UINT(rb_funcall(self, rb_intern("blue"),  0));

   return UINT2NUM(argb);
}