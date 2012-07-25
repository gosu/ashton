/*
 * class Ashton::Framebuffer
 *
 *
 */


#ifndef ASHTON_FRAMEBUFFER_H
#define ASHTON_FRAMEBUFFER_H

#include <math.h>

#include "common.h"
#include "pixel_cache.h"

VALUE rb_cFramebuffer;

typedef struct _framebuffer
{
    uint width;
    uint height;

    GLuint fbo_id;
    GLuint texture_id;

    VALUE rb_cache; // Value of cache for marking purpose.
} Framebuffer;

// Create an 'emitter' variable which points to our data.
#define FRAMEBUFFER() \
    Framebuffer* framebuffer; \
    Data_Get_Struct(self, Framebuffer, framebuffer);

void Init_Ashton_Framebuffer(VALUE module);

// Helpers
static void ensure_cache_exists(VALUE self, Framebuffer* framebuffer);

// Getters.
VALUE Ashton_Framebuffer_get_cache(VALUE self);
VALUE Ashton_Framebuffer_get_width(VALUE self);
VALUE Ashton_Framebuffer_get_height(VALUE self);
VALUE Ashton_Framebuffer_get_fbo_id(VALUE self);
VALUE Ashton_Framebuffer_get_texture_id(VALUE self);

// Creation and destruction.
VALUE Ashton_Framebuffer_singleton_new(int argc, VALUE* argv, VALUE klass);
VALUE Ashton_Framebuffer_init(VALUE self, VALUE width, VALUE height);
void Ashton_Framebuffer_FREE(Framebuffer* framebuffer);
void Ashton_Framebuffer_MARK(Framebuffer* framebuffer);

// Methods.
VALUE Ashton_Framebuffer_refresh_cache(VALUE self);
VALUE Ashton_Framebuffer_get_pixel(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_rgba_array(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_red(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_green(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_blue(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_alpha(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_is_transparent(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_to_blob(VALUE self);

#endif // ASHTON_FRAMEBUFFER_H

