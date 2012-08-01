/*
 * class Ashton::Texture
 *
 *
 */


#ifndef ASHTON_FRAMEBUFFER_H
#define ASHTON_FRAMEBUFFER_H

#include <math.h>

#include "common.h"
#include "pixel_cache.h"

VALUE rb_cTexture;
extern VALUE rb_cColor;
extern VALUE rb_cShader;

typedef struct _texture
{
    uint width;
    uint height;

    GLuint fbo_id;
    GLuint id;

    VALUE rb_cache; // Value of cache for marking purpose.
} Texture;

// Create an 'texture' variable which points to our data.
#define TEXTURE() \
    Texture* texture; \
    Data_Get_Struct(self, Texture, texture);

void Init_Ashton_Texture(VALUE module);

// Helpers
static VALUE texture_allocate(VALUE klass);
static void texture_mark(Texture* texture);
static void texture_free(Texture* texture);
static void ensure_cache_exists(VALUE self, Texture* texture);
static void ensure_fbo_exists(Texture* texture);

// Getters.
VALUE Ashton_Texture_get_cache(VALUE self);
VALUE Ashton_Texture_get_width(VALUE self);
VALUE Ashton_Texture_get_height(VALUE self);
VALUE Ashton_Texture_get_fbo_id(VALUE self);
VALUE Ashton_Texture_get_id(VALUE self);

// Creation and destruction.
VALUE Ashton_Texture_init(VALUE self, VALUE width, VALUE height, VALUE blob);

// Methods.
VALUE Ashton_Texture_refresh_cache(VALUE self);
VALUE Ashton_Texture_get_pixel(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Texture_get_rgba_array(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Texture_get_red(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Texture_get_green(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Texture_get_blue(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Texture_get_alpha(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Texture_is_transparent(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Texture_to_blob(VALUE self);
VALUE Ashton_Texture_draw(int argc, VALUE argv[], VALUE self);
VALUE Ashton_Texture_enable(VALUE self);

#endif // ASHTON_FRAMEBUFFER_H

