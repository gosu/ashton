#include "texture.h"

extern VALUE rb_cPixelCache;

void Init_Ashton_Texture(VALUE module)
{
    rb_cTexture = rb_define_class_under(module, "Texture", rb_cObject);

    rb_define_singleton_method(rb_cTexture, "new", Ashton_Texture_singleton_new, -1);

    rb_define_method(rb_cTexture, "initialize_", Ashton_Texture_init, 2);

    rb_define_method(rb_cTexture, "cache", Ashton_Texture_get_cache, 0);

    rb_define_method(rb_cTexture, "width", Ashton_Texture_get_width, 0);
    rb_define_method(rb_cTexture, "height", Ashton_Texture_get_height, 0);
    rb_define_method(rb_cTexture, "fbo_id", Ashton_Texture_get_fbo_id, 0);
    rb_define_method(rb_cTexture, "id", Ashton_Texture_get_id, 0);

    rb_define_method(rb_cTexture, "[]", Ashton_Texture_get_pixel, 2);
    rb_define_method(rb_cTexture, "rgba", Ashton_Texture_get_rgba_array, 2);
    rb_define_method(rb_cTexture, "red", Ashton_Texture_get_red, 2);
    rb_define_method(rb_cTexture, "green", Ashton_Texture_get_green, 2);
    rb_define_method(rb_cTexture, "blue", Ashton_Texture_get_blue, 2);
    rb_define_method(rb_cTexture, "alpha", Ashton_Texture_get_alpha, 2);

    rb_define_method(rb_cTexture, "transparent?", Ashton_Texture_is_transparent, 2);
    rb_define_method(rb_cTexture, "refresh_cache", Ashton_Texture_refresh_cache, 0);
    rb_define_method(rb_cTexture, "to_blob", Ashton_Texture_to_blob, 0);
}

//
VALUE Ashton_Texture_get_width(VALUE self)
{
    FRAMEBUFFER();
    return UINT2NUM(texture->width);
}

//
VALUE Ashton_Texture_get_height(VALUE self)
{
    FRAMEBUFFER();
    return UINT2NUM(texture->height);
}

VALUE Ashton_Texture_get_fbo_id(VALUE self)
{
    FRAMEBUFFER();
    return UINT2NUM(texture->fbo_id);
}

VALUE Ashton_Texture_get_id(VALUE self)
{
    FRAMEBUFFER();
    return UINT2NUM(texture->id);
}

//
VALUE Ashton_Texture_singleton_new(int argc, VALUE* argv, VALUE klass)
{
    Texture* texture;
    VALUE new_texture = Data_Make_Struct(klass, Texture, Ashton_Texture_MARK,
                                             Ashton_Texture_FREE, texture);

    rb_obj_call_init(new_texture, argc, argv);

    return new_texture;
}

//
VALUE Ashton_Texture_init(VALUE self, VALUE width, VALUE height)
{
    FRAMEBUFFER();

    if(!GL_EXT_framebuffer_object)
    {
       rb_raise(rb_eRuntimeError, "Ashton::Texture requires GL_EXT_framebuffer_object, which is not supported by OpenGL");
    }

    texture->width = NUM2UINT(width);
    texture->height = NUM2UINT(height);

    texture->rb_cache = Qnil;

    // Create the FBO itself.
    glGenFramebuffersEXT(1, &texture->fbo_id);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, texture->fbo_id);

    // Create the texture.
    glGenTextures(1, &texture->id);
    glBindTexture(GL_TEXTURE_2D, texture->id);

    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    // Create an empty texture, that might be filled with junk.
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, texture->width,
                texture->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                              GL_TEXTURE_2D, texture->id, 0);

    // Make everything safe again
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    return Qnil;
}

//
void Ashton_Texture_MARK(Texture* texture)
{
    if(!NIL_P(texture->rb_cache)) rb_gc_mark(texture->rb_cache);
}

//
void Ashton_Texture_FREE(Texture* texture)
{
    glDeleteFramebuffersEXT(1, &texture->fbo_id);
    glDeleteTextures(1, &texture->id);
}

//
static void ensure_cache_exists(VALUE self, Texture* texture)
{
    if(NIL_P(texture->rb_cache))
    {
        texture->rb_cache = rb_funcall(rb_cPixelCache, rb_intern("new"), 1, self);
    }
}

// Returns the cache. Creates it if necessary.
VALUE Ashton_Texture_get_cache(VALUE self)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return texture->rb_cache;
}

//
VALUE Ashton_Texture_get_pixel(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_get_pixel(texture->rb_cache, x, y);
}

VALUE Ashton_Texture_get_rgba_array(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_get_rgba_array(texture->rb_cache, x, y);
}

//
VALUE Ashton_Texture_get_red(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_get_red(texture->rb_cache, x, y);
}

//
VALUE Ashton_Texture_get_green(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_get_green(texture->rb_cache, x, y);
}

//
VALUE Ashton_Texture_get_blue(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_get_blue(texture->rb_cache, x, y);
}

//
VALUE Ashton_Texture_get_alpha(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_get_alpha(texture->rb_cache, x, y);
}

//
VALUE Ashton_Texture_is_transparent(VALUE self, VALUE x, VALUE y)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_is_transparent(texture->rb_cache, x, y);
}

VALUE Ashton_Texture_refresh_cache(VALUE self)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_refresh(texture->rb_cache);
}

VALUE Ashton_Texture_to_blob(VALUE self)
{
    FRAMEBUFFER();
    ensure_cache_exists(self, texture);
    return Ashton_PixelCache_to_blob(texture->rb_cache);
}