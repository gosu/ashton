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

GET_EMITTER_DATA(max_particles, max_particles, UINT2NUM);
GET_EMITTER_DATA(count, count, UINT2NUM);

// ----------------------------------------
void Init_Ashton_ParticleEmitter(VALUE module)
{
    VALUE rb_cParticleEmitter = rb_define_class_under(module, "ParticleEmitter", rb_cObject);

    rb_define_alloc_func(rb_cParticleEmitter, particle_emitter_allocate);

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
    rb_define_method(rb_cParticleEmitter, "color_argb", Ashton_ParticleEmitter_get_color_argb, 0);

    // Setters
    rb_define_method(rb_cParticleEmitter, "color_argb=", Ashton_ParticleEmitter_set_color_argb, 1);

    // Public methods.
    rb_define_method(rb_cParticleEmitter, "draw", Ashton_ParticleEmitter_draw, 0);
    rb_define_method(rb_cParticleEmitter, "emit", Ashton_ParticleEmitter_emit, 0);
    rb_define_method(rb_cParticleEmitter, "update", Ashton_ParticleEmitter_update, 0);
}

// ----------------------------------------
// Ashton::ParticleEmitter#initialize
VALUE Ashton_ParticleEmitter_init(VALUE self, VALUE x, VALUE y, VALUE z, VALUE max_particles)
{
    EMITTER();

//    if(!GL_ARB_vertex_buffer_object)
//    {
//       rb_raise(rb_eRuntimeError, "Ashton::ParticleEmitter requires GL_ARB_vertex_buffer_object, which is not supported by OpenGL");
//    }

    emitter->x = NUM2DBL(x);
    emitter->y = NUM2DBL(y);
    emitter->z = NUM2DBL(z);

    // Create space for all the particles we'll ever need!
    emitter->max_particles = NUM2UINT(max_particles);
    emitter->particles = ALLOC_N(Particle, emitter->max_particles);
    memset(emitter->particles, 0, emitter->max_particles * sizeof(Particle));

    // Setup VBO.
//    emitter->vertex_array = ALLOC_N(Vertex2d, emitter->max_particles * 4);
//    emitter->color_array = ALLOC_N(Color_f, emitter->max_particles);
//    glGenBuffersARB(1, &emitter->vbo_id);
//    glBufferDataARB(GL_ARRAY_BUFFER_ARB, sizeof(emitter->vertex_array) + sizeof(emitter->color_array),
//                    0, GL_STREAM_DRAW_ARB);
//    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, 0,
//                       sizeof(emitter->vertex_array), emitter->vertex_array);
//    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, sizeof(emitter->vertex_array),
//                       sizeof(emitter->color_array), emitter->color_array);
//    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);

    return self;
}

static VALUE particle_emitter_allocate(VALUE klass)
{
    ParticleEmitter* emitter = ALLOC(ParticleEmitter);
    memset(emitter, 0, sizeof(ParticleEmitter));

    return Data_Wrap_Struct(klass, NULL, particle_emitter_free, emitter);
}

// ----------------------------------------
// Deallocate data structure and its contents.
static void particle_emitter_free(ParticleEmitter* emitter)
{
//    glDeleteBuffersARB(1, &emitter->vbo_id);
//    xfree(emitter->vertex_array);
//    xfree(emitter->color_array);

    xfree(emitter->particles);
    xfree(emitter);
}

// === HELPERS ===

// ----------------------------------------
// Simple random numbers used by #deviate (0.0 <= randf() < 1.0)
inline static float randf()
{
    return (float)rand() / RAND_MAX;
}

// ----------------------------------------
// Deviate a value from a median value within a range.
inline static float deviate(Range * range)
{
  float deviation = (range->max - range->min) / 2.0;
  return range->min + deviation + randf() * deviation - randf() * deviation;
}

// ----------------------------------------
// Draw a single particle.
// TODO: Move this into Image#draw_rot ???
static void draw_particle(Particle* particle,
                          const uint width, const uint height,
                          const float tex_left, const float tex_top,
                          const float tex_right, const float tex_bottom)
{
    // Set the particle's color.
    Color_f* color = &particle->color;
    glColor4f(color->red, color->green, color->blue, color->alpha);

    // Totally ripped this code from Gosu :$
    float sizeX = width * particle->scale;
    float sizeY = height * particle->scale;
    float offsX = sin(particle->angle / 180 * M_PI);
    float offsY = cos(particle->angle / 180 * M_PI);

    float distToLeftX   = +offsY * sizeX * particle->center_x;
    float distToLeftY   = -offsX * sizeX * particle->center_x;
    float distToRightX  = -offsY * sizeX * (1 - particle->center_x);
    float distToRightY  = +offsX * sizeX * (1 - particle->center_x);
    float distToTopX    = +offsX * sizeY * particle->center_y;
    float distToTopY    = +offsY * sizeY * particle->center_y;
    float distToBottomX = -offsX * sizeY * (1 - particle->center_y);
    float distToBottomY = -offsY * sizeY * (1 - particle->center_y);

    glTexCoord2d(tex_left, tex_top);
    glVertex2d(particle->x + distToLeftX  + distToTopX,
               particle->y + distToLeftY  + distToTopY);

    glTexCoord2d(tex_right, tex_top);
    glVertex2d(particle->x + distToRightX + distToTopX,
               particle->y + distToRightY + distToTopY);

    glTexCoord2d(tex_right, tex_bottom);
    glVertex2d(particle->x + distToRightX + distToBottomX,
               particle->y + distToRightY + distToBottomY);

    glTexCoord2d(tex_left, tex_bottom);
    glVertex2d(particle->x + distToLeftX  + distToBottomX,
               particle->y + distToLeftY  + distToBottomY);
}

// ----------------------------------------
// Draw all particles from first to last (inclusive).
static void draw_particles(Particle* first, Particle* last,
                           const uint width, const uint height,
                           const float tex_left, const float tex_top,
                           const float tex_right, const float tex_bottom)
{
    Particle* particle = first;

    glBegin(GL_QUADS);
    for( ; particle <= last; particle++)
    {
        if(particle->time_to_live > 0)
        {
            draw_particle(particle, width, height, tex_left, tex_top, tex_right, tex_bottom);
        }
    }
    glEnd();

    return;
}

// ----------------------------------------
static VALUE enable_shader_block(VALUE yield_value, VALUE self, int argc, VALUE argv[])
{
    EMITTER();

    VALUE shader = rb_iv_get(self, "@shader");

    rb_funcall(shader, rb_intern("image="), 1, rb_iv_get(self, "@image"));
    rb_funcall(shader, rb_intern("color="), 1, UINT2NUM(color_to_argb(&emitter->color)));

    return Qnil;
}

// ----------------------------------------
static VALUE draw_block(VALUE yield_value, VALUE self, int argc, VALUE argv[])
{
    EMITTER();

    VALUE image = rb_iv_get(self, "@image");
    VALUE window = rb_gv_get("$window");

    // Bind the image that we will be using throughout and get its coordinates.
    VALUE tex_info = rb_funcall(image, rb_intern("gl_tex_info"), 0);
    int tex_id = NUM2INT(rb_funcall(tex_info, rb_intern("tex_name"), 0));
    float tex_left   = NUM2DBL(rb_funcall(tex_info, rb_intern("left"), 0));
    float tex_right  = NUM2DBL(rb_funcall(tex_info, rb_intern("right"), 0));
    float tex_top    = NUM2DBL(rb_funcall(tex_info, rb_intern("top"), 0));
    float tex_bottom = NUM2DBL(rb_funcall(tex_info, rb_intern("bottom"), 0));

    // Pixel size of image.
    uint width  = NUM2UINT(rb_funcall(image, rb_intern("width"), 0));
    uint height = NUM2UINT(rb_funcall(image, rb_intern("height"), 0));

    // Get ready to draw!
    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, tex_id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    // TODO: Work out whether it should be GL_LINEAR or GL_NEAREST.
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    // Ensure that drawing order is correct by drawing in reverse order of creation...

    // First, we draw all those from the current, going up to the last one.
    Particle* first = &emitter->particles[emitter->next_particle_index];
    Particle* last = &emitter->particles[emitter->max_particles - 1];
    draw_particles(first, last, width, height, tex_left, tex_top, tex_right, tex_bottom);

    // Then go from the first to the current.
    first = emitter->particles;
    last = &emitter->particles[emitter->next_particle_index - 1];
    draw_particles(first, last, width, height, tex_left, tex_top, tex_right, tex_bottom);

    return Qnil;
}

// ----------------------------------------
// Convert Color structure into 0xAARRGGBB value.
static uint color_to_argb(Color_f* color)
{
    uint argb = ((((uint)(color->alpha * 255.0)) & 0xff) << 24) +
                ((((uint)(color->red   * 255.0)) & 0xff) << 16) +
                ((((uint)(color->green * 255.0)) & 0xff) <<  8) +
                 (((uint)(color->blue  * 255.0)) & 0xff);

    return argb;
}

// === Getters & setters ===

// ----------------------------------------
// #color
VALUE Ashton_ParticleEmitter_get_color_argb(VALUE self)
{
    EMITTER();

    uint color = color_to_argb(&emitter->color);

    return UINT2NUM(color);
}

// ----------------------------------------
// #color=
VALUE Ashton_ParticleEmitter_set_color_argb(VALUE self, VALUE color)
{
    EMITTER();

    uint argb = NUM2UINT(color);

    emitter->color.alpha = ((argb >> 24) & 0xff) / 255.0;
    emitter->color.red   = ((argb >> 16) & 0xff) / 255.0;
    emitter->color.green = ((argb >>  8) & 0xff) / 255.0;
    emitter->color.blue  =  (argb        & 0xff) / 255.0;

    return color;
}

// === METHODS ===

// ----------------------------------------
// #draw
VALUE Ashton_ParticleEmitter_draw(VALUE self)
{
    EMITTER();

    if(emitter->count == 0) return Qnil;

    VALUE window = rb_gv_get("$window");
    VALUE shader = rb_iv_get(self, "@shader");
    VALUE z = rb_float_new(emitter->z);

    VALUE block_argv[1];
    block_argv[0] = z;

    // Enable the shader, if provided.
    if(!NIL_P(shader))
    {
        rb_funcall(shader, rb_intern("enable"), 1, z);
        // Setup the shader in another block, just for good luck :)

        rb_block_call(window, rb_intern("gl"), 1, block_argv,
                      RUBY_METHOD_FUNC(enable_shader_block), self);
    }

    rb_block_call(window, rb_intern("gl"), 1, block_argv,
                  RUBY_METHOD_FUNC(draw_block), self);

    // Disable the shader, if provided.
    if(!NIL_P(shader)) rb_funcall(shader, rb_intern("disable"), 1, z);

    return Qnil;
}

// ----------------------------------------
// #emit
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

    particle->color = emitter->color;

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

// ----------------------------------------
// #update
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
            particle->scale += particle->zoom * elapsed;

            // Fade out.
            particle->color.alpha *= 1 - (particle->fade * elapsed) / 255.0;

            particle->time_to_live -= elapsed;

            // Die if out of time, invisible or shrunk to nothing.
            if((particle->time_to_live <= 0) ||
                    (particle->color.alpha < 0) ||
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
