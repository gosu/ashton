/*
 * class Ashton::ParticleEmitter
 *
 */


#ifndef ASHTON_PARTICLE_EMITTER_H
#define ASHTON_PARTICLE_EMITTER_H

#include <math.h>

#include "common.h"

#define VERTICES_IN_PARTICLE 4

// A single particle.
typedef struct _particle
{
    // State.
    float x, y;
    float center_x, center_y;
    float velocity_x, velocity_y;
    float angular_velocity;

    Color_f color;

    // Rate of change
    float fade;
    float scale;
    float zoom;
    float friction;
    float angle;

    // Time to die.
    float time_to_live;
} Particle;

typedef struct _range
{
    float min, max;
} Range;

typedef struct _vertex2d
{
    float x, y;
} Vertex2d;

// The Ashton::ParticleEmitter's own data, including particles.
typedef struct _particle_emitter
{
    // Position of the emitter.
    float x, y, z;
    float gravity;

    // Generating particles.
    Range angular_velocity;
    Range center_x, center_y;
    Color_f color;
    Range fade;
    Range friction;
    Range offset; // Distance from origin to spawn.
    Range scale;
    Range speed;
    Range time_to_live;
    Range zoom;

    // When to emit.
    Range interval;
    float time_until_emit;

    // Managing the particles themselves.
    uint count; // Current number of active particles.
    uint max_particles; // No more will be created if max hit.
    uint next_particle_index; // Next place to create a new particle (either dead or oldest living).
    Particle* particles;

    // VBO and client-side data arrays.
    uint vbo_id;

    Color_i* color_array; // Color array.
    ulong color_array_offset; // Offset to colours within VBO.

    Vertex2d* texture_coord_array; // Tex coord array.
    ulong texture_coord_array_offset; // Offset to texture coords within VBO.

    Vertex2d* vertex_array; // Vertex array.
    ulong vertex_array_offset; // Offset to vertices within VBO.
} ParticleEmitter;


void Init_Ashton_ParticleEmitter(VALUE module);
static void init_vbo(ParticleEmitter* emitter);
static VALUE particle_emitter_allocate(VALUE klass);
static void particle_emitter_free(ParticleEmitter* emitter);

// Initialization
VALUE Ashton_ParticleEmitter_init(VALUE self, VALUE x, VALUE y, VALUE z, VALUE max_particles);

// Create an 'emitter' variable which points to our data.
#define EMITTER() \
    ParticleEmitter* emitter; \
    Data_Get_Struct(self, ParticleEmitter, emitter);


// Implementation of get/set functions .
#define GET_EMITTER_DATA(ATTRIBUTE_NAME, ATTRIBUTE, CAST) \
    VALUE Ashton_ParticleEmitter_get_##ATTRIBUTE_NAME(VALUE self) \
    { \
       EMITTER(); \
       return CAST(emitter->ATTRIBUTE); \
    }

#include "limits.h"
// BUG: Passing in Infinity seems to convert it to NaN!
#define SET_EMITTER_DATA(ATTRIBUTE_NAME, ATTRIBUTE, CAST) \
    VALUE Ashton_ParticleEmitter_set_##ATTRIBUTE_NAME(VALUE self, VALUE value) \
    { \
       EMITTER(); \
       emitter->ATTRIBUTE = CAST(value); \
       return value; \
    }

#define GET_SET_EMITTER_DATA(ATTRIBUTE, CAST_TO_RUBY, CAST_TO_C) \
    GET_EMITTER_DATA(ATTRIBUTE, ATTRIBUTE, CAST_TO_RUBY) \
    SET_EMITTER_DATA(ATTRIBUTE, ATTRIBUTE, CAST_TO_C)

#define GET_SET_EMITTER_DATA_RANGE(ATTRIBUTE, CAST_TO_RUBY, CAST_TO_C) \
    GET_EMITTER_DATA(ATTRIBUTE##_min, ATTRIBUTE.min, CAST_TO_RUBY) \
    SET_EMITTER_DATA(ATTRIBUTE##_min, ATTRIBUTE.min, CAST_TO_C)  \
    GET_EMITTER_DATA(ATTRIBUTE##_max, ATTRIBUTE.max, CAST_TO_RUBY) \
    SET_EMITTER_DATA(ATTRIBUTE##_max, ATTRIBUTE.max, CAST_TO_C)


// Define minimum and maximum get/set functions as methods.

// Define get/set functions as methods.
#define DEFINE_METHOD_GET_SET(ATTRIBUTE) \
    rb_define_method(rb_cParticleEmitter, #ATTRIBUTE, Ashton_ParticleEmitter_get_##ATTRIBUTE, 0); \
    rb_define_method(rb_cParticleEmitter, #ATTRIBUTE "=", Ashton_ParticleEmitter_set_##ATTRIBUTE, 1);

#define DEFINE_METHOD_GET_SET_RANGE(ATTRIBUTE) \
    DEFINE_METHOD_GET_SET(ATTRIBUTE##_min); \
    DEFINE_METHOD_GET_SET(ATTRIBUTE##_max);


VALUE Ashton_ParticleEmitter_get_color_argb(VALUE self);
VALUE Ashton_ParticleEmitter_set_color_argb(VALUE self, VALUE color);

// Helpers.
inline static float randf();
inline static float deviate(Range * range);
static void update_particle(ParticleEmitter* emitter, Particle* particle, const float delta);
static void update_vbo(ParticleEmitter* emitter, VALUE image);
static void draw_vbo(ParticleEmitter* emitter, const uint texture_id);
static void write_colors(Color_i* color, Particle* particle);
static void write_texture_coords(Vertex2d* texture_coord,
                                 const float tex_left, const float tex_top,
                                 const float tex_right, const float tex_bottom);
static void write_particle_vertices(Vertex2d* vertex, Particle* particle,
                                    const uint width, const uint height);
static uint write_particles(ParticleEmitter *emitter, Particle* first, Particle* last,
                            const uint width, const uint height,
                            const float tex_left, const float tex_top,
                            const float tex_right, const float tex_bottom,
                            const uint first_particle_index);

static uint color_to_argb(Color_f* color);

// Methods
VALUE Ashton_ParticleEmitter_draw(VALUE self);
VALUE Ashton_ParticleEmitter_emit(VALUE self);
VALUE Ashton_ParticleEmitter_update(VALUE self, VALUE delta);

#endif // ASHTON_PARTICLE_EMITTER_H

