/*
 * class Ashton::Framebuffer
 *
 *
 */


#ifndef ASHTON_FRAMEBUFFER_H
#define ASHTON_FRAMEBUFFER_H

#include <math.h>

#include "common.h"

extern VALUE rb_cColor;

typedef struct _color
{
    uchar red, green, blue, alpha;
} Color;

typedef struct _framebuffer
{
    uint width;
    uint height;

    GLuint fbo_id;
    GLuint texture_id;

    Color * cache;
    uint is_cached; // If false, then the cache data needs updating.
    uint cache_created; // Has space for the cache ever been allocated?
} Framebuffer;

// Create an 'emitter' variable which points to our data.
#define FRAMEBUFFER() \
    Framebuffer* framebuffer; \
    Data_Get_Struct(self, Framebuffer, framebuffer);

void Init_Ashton_Framebuffer(VALUE module);

// Helpers
static void cache_texture(Framebuffer* framebuffer);
static void refresh_cache(Framebuffer* framebuffer);
static Color get_pixel_color(Framebuffer* framebuffer, const int x, const int y);

// Getters.
VALUE Ashton_Framebuffer_get_width(VALUE self);
VALUE Ashton_Framebuffer_get_height(VALUE self);
VALUE Ashton_Framebuffer_get_fbo_id(VALUE self);
VALUE Ashton_Framebuffer_get_texture_id(VALUE self);

// Creation and destruction.
VALUE Ashton_Framebuffer_singleton_new(int argc, VALUE* argv, VALUE klass);
VALUE Ashton_Framebuffer_init(VALUE self, VALUE width, VALUE height);
void Ashton_Framebuffer_FREE(Framebuffer* framebuffer);

// Methods.
VALUE Ashton_Framebuffer_get_pixel(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_rgba_array(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_red(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_green(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_blue(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_get_alpha(VALUE self, VALUE x, VALUE y);
VALUE Ashton_Framebuffer_is_transparent(VALUE self, VALUE x, VALUE y);

VALUE Ashton_Framebuffer_refresh_cache(VALUE self);

#endif // ASHTON_FRAMEBUFFER_H

