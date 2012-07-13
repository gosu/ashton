#include "particle_emitter.h"


void Init_Ashton_ParticleEmitter(VALUE module)
{
    VALUE rb_cParticleEmitter = rb_define_class_under(module, "ParticleEmitter", rb_cObject);

    rb_define_singleton_method(rb_cParticleEmitter, "new", Ashton_ParticleEmitter_singleton_new, -1);

    rb_define_method(rb_cParticleEmitter, "initialize_", Ashton_ParticleEmitter_init, -1);

    // Getters/Setters.
    rb_define_method(rb_cParticleEmitter, "x", Ashton_ParticleEmitter_get_x, 0);
    rb_define_method(rb_cParticleEmitter, "y", Ashton_ParticleEmitter_get_y, 0);
    rb_define_method(rb_cParticleEmitter, "z", Ashton_ParticleEmitter_get_z, 0);

    rb_define_method(rb_cParticleEmitter, "max_particles", Ashton_ParticleEmitter_get_max_particles, 0);

    rb_define_method(rb_cParticleEmitter, "x=", Ashton_ParticleEmitter_set_x, 1);
    rb_define_method(rb_cParticleEmitter, "y=", Ashton_ParticleEmitter_set_y, 1);
    rb_define_method(rb_cParticleEmitter, "z=", Ashton_ParticleEmitter_set_z, 1);
    //rb_define_method(rb_cParticleEmitter, "max_particles=", Ashton_ParticleEmitter_set_max_particles, 1);


    // Protected.
    rb_define_protected_method(rb_cParticleEmitter, "deviate", Ashton_ParticleEmitter_deviate, 2);
}

// Ashton::ParticleEmitter.new(x, y, z, options = {})
VALUE Ashton_ParticleEmitter_singleton_new(int argc, VALUE* argv, VALUE klass)
{
    VALUE x, y, z, options;
    rb_scan_args(argc, argv, "31", &x, &y, &z, &options);

    ParticleEmitter* emitter_data;
    VALUE particle_emitter = Data_Make_Struct(klass, ParticleEmitter, NULL, Ashton_ParticleEmitter_FREE, emitter_data);

    rb_obj_call_init(particle_emitter, argc, argv);

    return particle_emitter;
}

// Ashton::ParticleEmitter#initialize(x, y, z, options = {})
VALUE Ashton_ParticleEmitter_init(int argc, VALUE* argv, VALUE self)
{
    VALUE x, y, z, options;
    rb_scan_args(argc, argv, "31", &x, &y, &z, &options);

    if(NIL_P(options)) { options = rb_hash_new(); }
    Check_Type(options, T_HASH);

    EMITTER_DATA();

    // max_particles = options[:max_particles] || DEFAULT_MAX_PARTICLES
//    VALUE max_particles = rb_hash_aref(options, ID2SYM(rb_intern("max_particles")));
//    if(NIL_P(max_particles))
//    {
//        max_particles = rb_const_get(self, rb_intern("DEFAULT_MAX_PARTICLES"));
//    }

    emitter_data->x = NUM2DBL(x);
    emitter_data->y = NUM2DBL(y);
    emitter_data->z = NUM2DBL(z);
    emitter_data->max_particles = 10; //NUM2INT(max_particles);
    emitter_data->particles = ALLOC_N(Particle, emitter_data->max_particles);

    return self;
}

// Deallocate data structure and its contents.
void Ashton_ParticleEmitter_FREE(ParticleEmitter* emitter_data)
{
    xfree(emitter_data->particles);
    xfree(emitter_data);
}

// Getters/setters.
GET_EMITTER_DATA(x, rb_float_new);
GET_EMITTER_DATA(y, rb_float_new);
GET_EMITTER_DATA(z, rb_float_new);
GET_EMITTER_DATA(max_particles, INT2NUM);

SET_EMITTER_DATA(x, NUM2DBL);
SET_EMITTER_DATA(y, NUM2DBL);
SET_EMITTER_DATA(z, NUM2DBL);

// Simple random numbers used by #deviate (0.0 <= randf() < 1.0)
inline static float randf()
{
    return (float)rand() / RAND_MAX;
}

// Ashton::ParticleEmitter#deviate(value, deviation)
VALUE Ashton_ParticleEmitter_deviate(VALUE self, VALUE value, VALUE deviation)
{
  float _value = NUM2DBL(value);
  float _deviation = NUM2DBL(deviation);

  float modification = 1 + randf() * _deviation - randf() * _deviation;

  return rb_float_new(_value * modification);
}