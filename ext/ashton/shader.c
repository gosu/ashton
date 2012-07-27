#include "shader.h"



// ----------------------------------------
void Init_Ashton_Shader(VALUE module)
{
    rb_cShader = rb_define_class_under(module, "Shader", rb_cObject);
}