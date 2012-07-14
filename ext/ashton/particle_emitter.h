/*
 * class Ashton::ParticleEmitter
 *
 */


#ifndef ASHTON_PARTICLE_EMITTER_H
#define ASHTON_PARTICLE_EMITTER_H

#include <ruby.h>
#include <math.h>

// A single particle.
typedef struct _particle
{
    // State.
    float x, y;
    float velocity_x, velocity_y;
    float alpha;
    //float angular_velocity;

    // Change
    float fade;
    float scale;
    float zoom;
    float friction;
    float angle;
    float time_to_live;
} Particle;


// The Ashton::ParticleEmitter's own data, including particles.
typedef struct _particle_emitter
{
    // Position of the emitter.
    float x, y, z;
    float gravity;

    // Generating particles.
    float fade, fade_deviation;
    float friction, friction_deviation;
    float offset, offset_deviation; // Distance from origin to spawn.
    float scale, scale_deviation;
    float speed, speed_deviation;
    float time_to_live, time_to_live_deviation;
    float zoom, zoom_deviation;

    // When to emit.
    float interval, interval_deviation;
    float time_until_emit;

    // Managing the particles themselves.
    int count; // Current number of active particles.
    int max_particles; // No more will be created if max hit.
    int next_particle_index; // Next place to create a new particle (either dead or oldest living).
    Particle* particles;
} ParticleEmitter;


void Init_Ashton_ParticleEmitter(VALUE module);

// Initialization
VALUE Ashton_ParticleEmitter_singleton_new(int argc, VALUE* argv, VALUE klass);
VALUE Ashton_ParticleEmitter_init(VALUE self, VALUE x, VALUE y, VALUE z, VALUE max_particles);

void Ashton_ParticleEmitter_FREE(ParticleEmitter* emitter);

// Create an 'emitter' variable which points to our data.
#define EMITTER() \
    ParticleEmitter* emitter; \
    Data_Get_Struct(self, ParticleEmitter, emitter);


// Implementation of get/set functions .
#define GET_EMITTER_DATA(ATTRIBUTE, CAST) \
    VALUE Ashton_ParticleEmitter_get_##ATTRIBUTE(VALUE self) \
    { \
       EMITTER(); \
       return CAST(emitter->ATTRIBUTE); \
    }

#define SET_EMITTER_DATA(ATTRIBUTE, CAST) \
    VALUE Ashton_ParticleEmitter_set_##ATTRIBUTE(VALUE self, VALUE value) \
    { \
       EMITTER(); \
       emitter->ATTRIBUTE = CAST(value); \
       return value; \
    }

#define GET_SET_EMITTER_DATA(ATTRIBUTE, CAST_TO_RUBY, CAST_TO_C) \
    GET_EMITTER_DATA(ATTRIBUTE, CAST_TO_RUBY) \
    SET_EMITTER_DATA(ATTRIBUTE, CAST_TO_C)

#define GET_SET_EMITTER_DATA_WITH_DEVIATION(ATTRIBUTE, CAST_TO_RUBY, CAST_TO_C) \
    GET_SET_EMITTER_DATA(ATTRIBUTE, CAST_TO_RUBY, CAST_TO_C) \
    GET_SET_EMITTER_DATA(ATTRIBUTE##_deviation, CAST_TO_RUBY, CAST_TO_C)

// Define get/set functions as methods.
#define DEFINE_METHOD_GET_SET(ATTRIBUTE) \
    rb_define_method(rb_cParticleEmitter, #ATTRIBUTE, Ashton_ParticleEmitter_get_##ATTRIBUTE, 0); \
    rb_define_method(rb_cParticleEmitter, #ATTRIBUTE "=", Ashton_ParticleEmitter_set_##ATTRIBUTE, 1);

#define DEFINE_METHOD_GET_SET_WITH_DEVIATION(ATTRIBUTE) \
    DEFINE_METHOD_GET_SET(ATTRIBUTE); \
    DEFINE_METHOD_GET_SET(ATTRIBUTE##_deviation);

// Helpers.
inline static float randf();
inline static float deviate(float value, float deviation);
static void draw_particle(Particle* particle, VALUE image, VALUE z, VALUE color);
static VALUE enable_shader_block(VALUE yield_value, VALUE self, int argc, VALUE argv[]);


// Methods
VALUE Ashton_ParticleEmitter_draw(VALUE self);
VALUE Ashton_ParticleEmitter_emit(VALUE self);
VALUE Ashton_ParticleEmitter_update(VALUE self);

#endif // ASHTON_PARTICLE_EMITTER_H

