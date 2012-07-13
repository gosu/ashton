/*
 * class Ashton::ParticleEmitter
 *
 */


#ifndef ASHTON_PARTICLE_EMITTER_H
#define ASHTON_PARTICLE_EMITTER_H

#include <ruby.h>

// A single particle.
typedef struct _particle
{
    float x, y;
    float velocity_x, velocity_y;

    float friction;
    float angle;
    float angular_velocity;
} Particle;


// The Ashton::ParticleEmitter's own data, including particles.
typedef struct _particle_emitter
{
    float x, y, z;

    float position_deviation;
    float speed, speed_deviation;
    float fade, fade_deviation;
    float zoom, zoom_deviation;

    int max_particles;
    Particle* particles;
} ParticleEmitter;


void Init_Ashton_ParticleEmitter(VALUE module);

// Initialization
VALUE Ashton_ParticleEmitter_singleton_new(int argc, VALUE* argv, VALUE klass);
VALUE Ashton_ParticleEmitter_init(int argc, VALUE* argv, VALUE self);
void Ashton_ParticleEmitter_FREE(ParticleEmitter* emitter_data);

// Create an 'emitter_data' variable which points to our data.
#define EMITTER_DATA() \
    ParticleEmitter* emitter_data; \
    Data_Get_Struct(self, ParticleEmitter, emitter_data);


#define GET_EMITTER_DATA(ATTRIBUTE, CAST) \
    VALUE Ashton_ParticleEmitter_get_##ATTRIBUTE(VALUE self) \
    { \
       EMITTER_DATA(); \
       return CAST(emitter_data->ATTRIBUTE); \
    }

#define SET_EMITTER_DATA(ATTRIBUTE, CAST) \
    VALUE Ashton_ParticleEmitter_set_##ATTRIBUTE(VALUE self, VALUE value) \
    { \
       EMITTER_DATA(); \
       emitter_data->ATTRIBUTE = CAST(value); \
       return value; \
    }

// Getters/setters
VALUE Ashton_ParticleEmitter_get_x(VALUE self);
VALUE Ashton_ParticleEmitter_get_y(VALUE self);
VALUE Ashton_ParticleEmitter_get_z(VALUE self);
VALUE Ashton_ParticleEmitter_get_max_particles(VALUE self);

VALUE Ashton_ParticleEmitter_set_x(VALUE self, VALUE value);
VALUE Ashton_ParticleEmitter_set_y(VALUE self, VALUE value);
VALUE Ashton_ParticleEmitter_set_z(VALUE self, VALUE value);
//VALUE Ashton_ParticleEmitter_set_max_particles(VALUE self, VALUE value);

// Methods
inline static float randf();
VALUE Ashton_ParticleEmitter_deviate(VALUE self, VALUE value, VALUE deviation);


#endif // ASHTON_PARTICLE_EMITTER_H

