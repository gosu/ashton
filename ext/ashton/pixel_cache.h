/*
 * class Ashton::PixelCache
 *
 *
 */


#ifndef ASHTON_PIXEL_CACHE_H
#define ASHTON_PIXEL_CACHE_H

#include <math.h>

#include "common.h"

VALUE rb_cPixelCache;
extern VALUE rb_cImage;
extern VALUE rb_cColor;
extern VALUE rb_cTexture;

typedef struct _pixel_cache
{
    float x;
    float y;

    uint width;
    uint height;

    VALUE rb_owner; // Texture or Image object (held for marking purposes).
    uint texture_id; // Direct access to the owner's texture.
    
    Color_i* data; // The actual "blob" data.

    bool is_cached; // If false, then the cache data needs updating.
    bool is_created; // Has space for the cache ever been allocated?
} PixelCache;

#define PIXEL_CACHE() \
    PixelCache* pixel_cache; \
    Data_Get_Struct(self, PixelCache, pixel_cache);

void Init_Ashton_PixelCache(VALUE module);
    
// Helpers
static void cache_texture(PixelCache* pixel_cache);
static Color_i get_pixel_color(PixelCache* pixel_cache, VALUE x, VALUE y);

// Creation and destruction.
VALUE Ashton_PixelCache_singleton_new(int argc, VALUE* argv, VALUE klass);
VALUE Ashton_PixelCache_init(VALUE self, VALUE owner);
void Ashton_PixelCache_FREE(PixelCache* pixel_cache);
void Ashton_PixelCache_MARK(PixelCache* pixel_cache);

// Accessors
VALUE Ashton_PixelCache_get_owner(VALUE self);
VALUE Ashton_PixelCache_get_width(VALUE self);
VALUE Ashton_PixelCache_get_height(VALUE self);

// Methods.
VALUE Ashton_PixelCache_get_pixel(VALUE self, VALUE x, VALUE y);
VALUE Ashton_PixelCache_get_rgba_array(VALUE self, VALUE x, VALUE y);
VALUE Ashton_PixelCache_get_red(VALUE self, VALUE x, VALUE y);
VALUE Ashton_PixelCache_get_green(VALUE self, VALUE x, VALUE y);
VALUE Ashton_PixelCache_get_blue(VALUE self, VALUE x, VALUE y);
VALUE Ashton_PixelCache_get_alpha(VALUE self, VALUE x, VALUE y);
VALUE Ashton_PixelCache_is_transparent(VALUE self, VALUE x, VALUE y);

VALUE Ashton_PixelCache_refresh(VALUE self);
VALUE Ashton_PixelCache_to_blob(VALUE self);
   
#endif // ASHTON_PIXEL_CACHE_H