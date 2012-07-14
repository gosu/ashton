#include "particle_emitter.h"


// === GETTERS & SETTERS ===
GET_SET_EMITTER_DATA(x, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA(y, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA(z, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA(gravity, rb_float_new, NUM2DBL);

GET_SET_EMITTER_DATA_RANGE(center_x, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(center_y, rb_float_new, NUM2DBL);

GET_SET_EMITTER_DATA_RANGE(angular_velocity, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(fade, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(friction, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(interval, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(offset, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(scale, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(speed, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(time_to_live, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(zoom, rb_float_new, NUM2DBL);

GET_EMITTER_DATA(max_particles, max_particles, INT2NUM);
GET_EMITTER_DATA(count, count, INT2NUM);

void Init_Ashton_ParticleEmitter(VALUE module)
{
    VALUE rb_cParticleEmitter = rb_define_class_under(module, "ParticleEmitter", rb_cObject);

    rb_define_singleton_method(rb_cParticleEmitter, "new", Ashton_ParticleEmitter_singleton_new, -1);

    rb_define_method(rb_cParticleEmitter, "initialize_", Ashton_ParticleEmitter_init, 4);

    // Getters & Setters
    DEFINE_METHOD_GET_SET(x);
    DEFINE_METHOD_GET_SET(y);
    DEFINE_METHOD_GET_SET(z);
    DEFINE_METHOD_GET_SET(gravity);

    DEFINE_METHOD_GET_SET_RANGE(angular_velocity);
    DEFINE_METHOD_GET_SET_RANGE(center_x);
    DEFINE_METHOD_GET_SET_RANGE(center_y);
    DEFINE_METHOD_GET_SET_RANGE(fade);
    DEFINE_METHOD_GET_SET_RANGE(friction);
    DEFINE_METHOD_GET_SET_RANGE(interval);
    DEFINE_METHOD_GET_SET_RANGE(offset);
    DEFINE_METHOD_GET_SET_RANGE(scale);
    DEFINE_METHOD_GET_SET_RANGE(speed);
    DEFINE_METHOD_GET_SET_RANGE(time_to_live);
    DEFINE_METHOD_GET_SET_RANGE(zoom);

    // Getters
    rb_define_method(rb_cParticleEmitter, "count", Ashton_ParticleEmitter_get_count, 0);
    rb_define_method(rb_cParticleEmitter, "max_particles", Ashton_ParticleEmitter_get_max_particles, 0);

    // Setters

    // Public methods.
    rb_define_method(rb_cParticleEmitter, "draw", Ashton_ParticleEmitter_draw, 0);
    rb_define_method(rb_cParticleEmitter, "emit", Ashton_ParticleEmitter_emit, 0);
    rb_define_method(rb_cParticleEmitter, "update", Ashton_ParticleEmitter_update, 0);
}

// Ashton::ParticleEmitter.new(x, y, z, options = {})
VALUE Ashton_ParticleEmitter_singleton_new(int argc, VALUE* argv, VALUE klass)
{
    ParticleEmitter* emitter;
    VALUE particle_emitter = Data_Make_Struct(klass, ParticleEmitter, NULL, Ashton_ParticleEmitter_FREE, emitter);

    rb_obj_call_init(particle_emitter, argc, argv);

    return particle_emitter;
}

// Ashton::ParticleEmitter#initialize
VALUE Ashton_ParticleEmitter_init(VALUE self, VALUE x, VALUE y, VALUE z, VALUE max_particles)
{
    EMITTER();

    emitter->x = NUM2DBL(x);
    emitter->y = NUM2DBL(y);
    emitter->z = NUM2DBL(z);

    // Create space for all the particles we'll ever need!
    emitter->max_particles = NUM2DBL(max_particles);
    emitter->particles = ALLOC_N(Particle, emitter->max_particles);
    memset(emitter->particles, 0, emitter->max_particles * sizeof(Particle));

    return self;
}

// Deallocate data structure and its contents.
void Ashton_ParticleEmitter_FREE(ParticleEmitter* emitter)
{
    xfree(emitter->particles);
    xfree(emitter);
}

// === HELPERS ===
// Simple random numbers used by #deviate (0.0 <= randf() < 1.0)
inline static float randf()
{
    return (float)rand() / RAND_MAX;
}

// Deviate a value from a median value within a range.
inline static float deviate(Range * range)
{
  float deviation = (range->max - range->min) / 2.0;
  return range->min + deviation + randf() * deviation - randf() * deviation;
}

// Draw a single particle.
static void draw_particle(Particle* particle, VALUE image, VALUE z, VALUE color)
{
    VALUE scale = rb_float_new(particle->scale);

    rb_funcall(image, rb_intern("draw_rot_without_hash"), 9,
               rb_float_new(particle->x), rb_float_new(particle->y), z,
               rb_float_new(particle->angle),
               rb_float_new(particle->center_x), rb_float_new(particle->center_y),
               scale, scale, color);
}

static VALUE enable_shader_block(VALUE yield_value, VALUE context, int argc, VALUE argv[])
{
    VALUE shader = rb_iv_get(context, "@shader");

    rb_funcall(shader, rb_intern("image="), 1, rb_iv_get(context, "@image"));
    rb_funcall(shader, rb_intern("color="), 1, rb_iv_get(context, "@color"));

    return Qnil;
}

// === METHODS ===
VALUE Ashton_ParticleEmitter_draw(VALUE self)
{
    EMITTER();

    if(emitter->count == 0) return Qnil;

    VALUE image = rb_iv_get(self, "@image");
    VALUE color = rb_iv_get(self, "@color");
    VALUE shader = rb_iv_get(self, "@shader");
    VALUE z = rb_float_new(emitter->z);
    VALUE window = rb_gv_get("$window");

    if(!NIL_P(shader))
    {
        rb_funcall(shader, rb_intern("enable"), 1, z);
        // Setup the shader in another block, just for good luck :)
        VALUE block_argv[1];
        block_argv[0] = z;
        rb_block_call(window, rb_intern("gl"), 1, block_argv,
                      RUBY_METHOD_FUNC(enable_shader_block), self);
    }

    // Ensure that drawing order is correct by drawing in reverse order of creation...

    // First, we draw all those from the current, going up to the last one.
    Particle* particle = &emitter->particles[emitter->next_particle_index];
    Particle* last = &emitter->particles[emitter->max_particles];
    for( ; particle < last; particle++)
    {
        if(particle->time_to_live > 0)
        {
            draw_particle(particle, image, z, color);
        }
    }

    // Then go from the first to the current.
    particle = emitter->particles;
    last = &emitter->particles[emitter->next_particle_index];
    for( ; particle < last; particle++)
    {
        if(particle->time_to_live > 0)
        {
            draw_particle(particle, image, z, color);
        }
    }

    if(!NIL_P(shader)) rb_funcall(shader, rb_intern("disable"), 1, z);

    return Qnil;
}

// Generate a single particle.
VALUE Ashton_ParticleEmitter_emit(VALUE self)
{
    EMITTER();

    // Find the first dead particle in the heap, or overwrite the oldest one.
    Particle* particle = &emitter->particles[emitter->next_particle_index];

    // If we are replacing an old one, remove it from the count and clear it to fresh.
    if(particle->time_to_live > 0)
    {
        // Kill off and replace one with time to live :(
        memset(particle, 0, sizeof(Particle));
    }
    else
    {
        emitter->count++; // Dead or never been used.
    }

    // Lets move the index onto the next one, or loop around.
    emitter->next_particle_index = (emitter->next_particle_index + 1) % emitter->max_particles;

    // Which way will the particle move?
    float movement_angle = randf() * 360;
    float speed = deviate(&emitter->speed);

    // How far away from the origin will the particle spawn?
    float offset = deviate(&emitter->offset);
    float position_angle = randf() * 360;

    particle->angle = position_angle; // TODO: Which initial facing?
    particle->x = emitter->x + sin(position_angle) * offset;
    particle->y = emitter->y + cos(position_angle) * offset;
    particle->velocity_x = sin(movement_angle) * speed;
    particle->velocity_y = cos(movement_angle) * speed;

    particle->angular_velocity = deviate(&emitter->angular_velocity);
    particle->center_x = deviate(&emitter->center_x);
    particle->center_y = deviate(&emitter->center_y);
    particle->fade = deviate(&emitter->fade);
    particle->friction = deviate(&emitter->friction);
    particle->scale = deviate(&emitter->scale);
    particle->time_to_live = deviate(&emitter->time_to_live);
    particle->zoom = deviate(&emitter->zoom);

    return Qnil;
}

VALUE Ashton_ParticleEmitter_update(VALUE self)
{
    EMITTER();

    float elapsed = 0.017; // TODO: Get this time from somewhere more useful.

    Particle* particle = emitter->particles;
    Particle* last = &emitter->particles[emitter->max_particles];
    for(; particle < last; particle++)
    {
        // Ignore particles that are already dead.
        if(particle->time_to_live > 0)
        {
            // Apply friction
            particle->velocity_x *= 1.0 - particle->friction * elapsed;
            particle->velocity_y *= 1.0 - particle->friction * elapsed;

            // Gravity.
            particle->velocity_y += emitter->gravity * elapsed;

            // Move
            particle->x += particle->velocity_x * elapsed;
            particle->y += particle->velocity_y * elapsed;

            // Rotate.
            particle->angle += particle->angular_velocity * elapsed;
            // Resize.
            particle->scale *= 1.0 + (particle->zoom * elapsed);
            // Fade out.
            particle->alpha *= 1.0 - (particle->fade * elapsed);

            particle->time_to_live -= elapsed;

            // Die if out of time, invisible or shrunk to nothing.
            if((particle->time_to_live <= 0) ||
                    (particle->alpha < 0) ||
                    (particle->scale < 0))
            {
                particle->time_to_live = 0;
                emitter->count -= 1;
            }
        }
    }

    // Time to emit one (or more) new particles?
    emitter->time_until_emit -= elapsed;
    while(emitter->time_until_emit <= 0)
    {
        rb_funcall(self, rb_intern("emit"), 0);
        emitter->time_until_emit += deviate(&emitter->interval);
    }

    return Qnil;
}
