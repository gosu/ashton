#include "framebuffer.h"

void Init_Ashton_Framebuffer(VALUE module)
{
    VALUE rb_cFramebuffer = rb_define_class_under(module, "Framebuffer", rb_cObject);

    rb_define_singleton_method(rb_cFramebuffer, "new", Ashton_Framebuffer_singleton_new, -1);

    rb_define_method(rb_cFramebuffer, "initialize_", Ashton_Framebuffer_init, 2);

    rb_define_method(rb_cFramebuffer, "width", Ashton_Framebuffer_get_width, 0);
    rb_define_method(rb_cFramebuffer, "height", Ashton_Framebuffer_get_height, 0);
    rb_define_method(rb_cFramebuffer, "fbo_id", Ashton_Framebuffer_get_fbo_id, 0);
    rb_define_method(rb_cFramebuffer, "texture_id", Ashton_Framebuffer_get_texture_id, 0);

    rb_define_method(rb_cFramebuffer, "[]", Ashton_Framebuffer_get_pixel, 2);
    rb_define_method(rb_cFramebuffer, "rgba", Ashton_Framebuffer_get_rgba_array, 2);
    rb_define_method(rb_cFramebuffer, "red", Ashton_Framebuffer_get_red, 2);
    rb_define_method(rb_cFramebuffer, "green", Ashton_Framebuffer_get_green, 2);
    rb_define_method(rb_cFramebuffer, "blue", Ashton_Framebuffer_get_blue, 2);
    rb_define_method(rb_cFramebuffer, "alpha", Ashton_Framebuffer_get_alpha, 2);

    rb_define_method(rb_cFramebuffer, "transparent?", Ashton_Framebuffer_is_transparent, 2);
    rb_define_method(rb_cFramebuffer, "refresh_cache", Ashton_Framebuffer_refresh_cache, 0);
}

//
VALUE Ashton_Framebuffer_get_width(VALUE self)
{
    FRAMEBUFFER();

    return UINT2NUM(framebuffer->width);
}

//
VALUE Ashton_Framebuffer_get_height(VALUE self)
{
    FRAMEBUFFER();

    return UINT2NUM(framebuffer->height);
}

VALUE Ashton_Framebuffer_get_fbo_id(VALUE self)
{
    FRAMEBUFFER();

    return UINT2NUM(framebuffer->fbo_id);
}

VALUE Ashton_Framebuffer_get_texture_id(VALUE self)
{
    FRAMEBUFFER();

    return UINT2NUM(framebuffer->texture_id);
}

//
VALUE Ashton_Framebuffer_singleton_new(int argc, VALUE* argv, VALUE klass)
{
    Framebuffer* framebuffer;
    VALUE new_framebuffer = Data_Make_Struct(klass, Framebuffer, NULL, Ashton_Framebuffer_FREE, framebuffer);

    rb_obj_call_init(new_framebuffer, argc, argv);

    return new_framebuffer;
}

//
VALUE Ashton_Framebuffer_init(VALUE self, VALUE width, VALUE height)
{
    FRAMEBUFFER();

    if(!GLEE_EXT_framebuffer_object)
    {
       rb_raise(rb_eRuntimeError, "Ashton::Framebuffer requires GL_EXT_framebuffer_object, which is not supported by OpenGL");
    }

    framebuffer->width = NUM2UINT(width);
    framebuffer->height = NUM2UINT(height);

    framebuffer->is_cached = FALSE;
    framebuffer->cache_created = FALSE;

    // Create the FBO itself.
    glGenFramebuffersEXT(1, &framebuffer->fbo_id);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, framebuffer->fbo_id);

    // Create the texture.
    glGenTextures(1, &framebuffer->texture_id);
    glBindTexture(GL_TEXTURE_2D, framebuffer->texture_id);

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    // Create an empty texture, that might be filled with junk.
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, framebuffer->width,
                framebuffer->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                              GL_TEXTURE_2D, framebuffer->texture_id, 0);

    // Make everything safe again
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    return Qnil;
}

//
void Ashton_Framebuffer_FREE(Framebuffer* framebuffer)
{
    xfree(framebuffer->cache);
    glDeleteFramebuffersEXT(1, &framebuffer->fbo_id);
    glDeleteTextures(1, &framebuffer->texture_id);
}

// Make a copy of the framebuffer texture in main memory.
static void cache_texture(Framebuffer* framebuffer)
{
    if(!framebuffer->cache_created)
    {
        framebuffer->cache = ALLOC_N(Color, framebuffer->width * framebuffer->height);
        framebuffer->cache_created = TRUE;
    }

    glBindTexture(GL_TEXTURE_2D, framebuffer->texture_id);
    glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, framebuffer->cache);

    framebuffer->is_cached = TRUE;
}

static void refresh_cache(Framebuffer* framebuffer)
{
    // Lazy refresh - we take a new copy only when we access it next.
    framebuffer->is_cached = FALSE;
}

// Get color of a single pixel.
static Color get_pixel_color(Framebuffer* framebuffer, const int x, const int y)
{
    if(x < 0 || x >= (int)framebuffer->width ||
       y < 0 || y >= (int)framebuffer->height)
    {
        Color color;
        memset(&color, 0, sizeof(Color));
        return color;
    }
    else
    {
        if(!framebuffer->is_cached)
        {
           cache_texture(framebuffer);
        }

        return framebuffer->cache[x + (framebuffer->height - 1 - y) * framebuffer->width];
    }
}

//
VALUE Ashton_Framebuffer_refresh_cache(VALUE self)
{
    FRAMEBUFFER();

    refresh_cache(framebuffer);

    return Qnil;
}

//
VALUE Ashton_Framebuffer_get_pixel(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();

    Color rgba = get_pixel_color(framebuffer, NUM2INT(x), NUM2INT(y));

    VALUE color = rb_funcall(rb_cColor, rb_intern("new"), 1,
                             UINT2NUM((rgba.alpha << 24) +
                                      (rgba.red   << 16) +
                                      (rgba.green <<  8) +
                                       rgba.blue));

    return color;
}

VALUE Ashton_Framebuffer_get_rgba_array(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();

    Color rgba = get_pixel_color(framebuffer, NUM2INT(x), NUM2INT(y));

    VALUE array = rb_ary_new();
    rb_ary_push(array, UINT2NUM(rgba.red));
    rb_ary_push(array, UINT2NUM(rgba.green));
    rb_ary_push(array, UINT2NUM(rgba.blue));
    rb_ary_push(array, UINT2NUM(rgba.alpha));

    return array;
}

//
VALUE Ashton_Framebuffer_get_red(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    Color rgba = get_pixel_color(framebuffer, NUM2INT(x), NUM2INT(y));
    return UINT2NUM(rgba.red);
}

//
VALUE Ashton_Framebuffer_get_green(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    Color rgba = get_pixel_color(framebuffer, NUM2INT(x), NUM2INT(y));
    return UINT2NUM(rgba.green);
}

//
VALUE Ashton_Framebuffer_get_blue(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    Color rgba = get_pixel_color(framebuffer, NUM2INT(x), NUM2INT(y));
    return UINT2NUM(rgba.blue);
}

//
VALUE Ashton_Framebuffer_get_alpha(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    Color rgba = get_pixel_color(framebuffer, NUM2INT(x), NUM2INT(y));
    return UINT2NUM(rgba.alpha);
}

//
VALUE Ashton_Framebuffer_is_transparent(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();

    Color rgba = get_pixel_color(framebuffer, NUM2INT(x), NUM2INT(y));

    return (rgba.alpha == 0) ? Qtrue : Qfalse;
}