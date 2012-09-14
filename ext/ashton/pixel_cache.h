/*
 * class Ashton::PixelCache
 *
 *
 */


#ifndef ASHTON_PIXEL_CACHE_H
#define ASHTON_PIXEL_CACHE_H

#include <math.h>

#include "common.h"

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

// Creation and destruction.
VALUE Ashton_PixelCache_init(VALUE self, VALUE owner);

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