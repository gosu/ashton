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
GET_SET_EMITTER_DATA_RANGE(offset, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(scale, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(speed, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(time_to_live, rb_float_new, NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(zoom, rb_float_new, NUM2DBL);

GET_EMITTER_DATA(max_particles, max_particles, UINT2NUM);
GET_EMITTER_DATA(count, count, UINT2NUM);

// Special case of interval, since that should also alter the time until emission.

//
VALUE Ashton_ParticleEmitter_set_interval_min(VALUE self, VALUE value)
{
    EMITTER();
    emitter->interval.min = NUM2DBL(value);
    emitter->time_until_emit = deviate(&emitter->interval);
    return value;
}

//
VALUE Ashton_ParticleEmitter_get_interval_min(VALUE self)
{
    EMITTER();
    return rb_float_new(emitter->interval.min);
}

//
VALUE Ashton_ParticleEmitter_set_interval_max(VALUE self, VALUE value)
{
    EMITTER();
    emitter->interval.max = NUM2DBL(value);
    emitter->time_until_emit = deviate(&emitter->interval);
    return value;
}

//
VALUE Ashton_ParticleEmitter_get_interval_max(VALUE self)
{
    EMITTER();
    return rb_float_new(emitter->interval.max);
}

// ----------------------------------------
void Init_Ashton_ParticleEmitter(VALUE module)
{
    initialize_fast_math(); // Needed to save HUGE amount of time calculating sin/cos all the time!

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
    rb_define_method(rb_cParticleEmitter, "update", Ashton_ParticleEmitter_update, 1);
}

// ----------------------------------------
// Ashton::ParticleEmitter#initialize
VALUE Ashton_ParticleEmitter_init(VALUE self, VALUE x, VALUE y, VALUE z, VALUE max_particles)
{
    EMITTER();

    emitter->x = NUM2DBL(x);
    emitter->y = NUM2DBL(y);
    emitter->z = NUM2DBL(z);

    // Create space for all the particles we'll ever need!
    emitter->max_particles = NUM2UINT(max_particles);

    init_vbo(emitter);

    emitter->particles = ALLOC_N(Particle, emitter->max_particles);
    memset(emitter->particles, 0, emitter->max_particles * sizeof(Particle));

    return self;
}

//
static void init_vbo(ParticleEmitter* emitter)
{
    if(!GL_ARB_vertex_buffer_object)
    {
       rb_raise(rb_eRuntimeError, "Ashton::ParticleEmitter requires GL_ARB_vertex_buffer_object, which is not supported by your OpenGL");
    }

    int num_vertices = emitter->max_particles * VERTICES_IN_PARTICLE;

    emitter->color_array = ALLOC_N(Color_i, num_vertices);
    emitter->color_array_offset = 0;

    emitter->texture_coord_array = ALLOC_N(Vertex2d, num_vertices);
    emitter->texture_coord_array_offset = sizeof(Color_i) * num_vertices;

    emitter->vertex_array = ALLOC_N(Vertex2d, num_vertices);
    emitter->vertex_array_offset = (sizeof(Color_i) + sizeof(Vertex2d)) * num_vertices;

    // Create the VBO, but don't upload any data yet.
    int data_size = (sizeof(Color_i) + sizeof(Vertex2d) + sizeof(Vertex2d)) * num_vertices;
    glGenBuffersARB(1, &emitter->vbo_id);
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, emitter->vbo_id);
    glBufferDataARB(GL_ARRAY_BUFFER_ARB, data_size, NULL, GL_STREAM_DRAW_ARB);

    // Check the buffer was actually created.
    int buffer_size = 0;
    glGetBufferParameterivARB(GL_ARRAY_BUFFER_ARB, GL_BUFFER_SIZE_ARB, &buffer_size);
    if(buffer_size != data_size)
    {
        rb_raise(rb_eRuntimeError, "Failed to create a VBO [%d bytes] to hold emitter data.", data_size);
    }

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);

    return;
}

//
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
    glDeleteBuffersARB(1, &emitter->vbo_id);
    xfree(emitter->color_array);
    xfree(emitter->texture_coord_array);
    xfree(emitter->vertex_array);

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
// Calculate the vertices.
static void write_particle_vertices(Vertex2d* vertex, Particle* particle,
                                        const uint width, const uint height)
{
    // Totally ripped this code from Gosu :$
    float sizeX = width * particle->scale;
    float sizeY = height * particle->scale;

    float offsX = fast_sin_deg(particle->angle);
    float offsY = fast_cos_deg(particle->angle);

    float distToLeftX   = +offsY * sizeX * particle->center_x;
    float distToLeftY   = -offsX * sizeX * particle->center_x;
    float distToRightX  = -offsY * sizeX * (1 - particle->center_x);
    float distToRightY  = +offsX * sizeX * (1 - particle->center_x);
    float distToTopX    = +offsX * sizeY * particle->center_y;
    float distToTopY    = +offsY * sizeY * particle->center_y;
    float distToBottomX = -offsX * sizeY * (1 - particle->center_y);
    float distToBottomY = -offsY * sizeY * (1 - particle->center_y);

    vertex->x = particle->x + distToLeftX  + distToTopX;
    vertex->y = particle->y + distToLeftY  + distToTopY;
    vertex++;

    vertex->x = particle->x + distToRightX + distToTopX;
    vertex->y = particle->y + distToRightY + distToTopY;
    vertex++;

    vertex->x = particle->x + distToRightX + distToBottomX;
    vertex->y = particle->y + distToRightY + distToBottomY;
    vertex++;

    vertex->x = particle->x + distToLeftX  + distToBottomX;
    vertex->y = particle->y + distToLeftY  + distToBottomY;
}

// ----------------------------------------
static void write_texture_coords(Vertex2d* texture_coord,
                                     const float tex_left, const float tex_top,
                                     const float tex_right, const float tex_bottom)
{
    texture_coord->x = tex_left;
    texture_coord->y = tex_top;
    texture_coord++;

    texture_coord->x = tex_right;
    texture_coord->y = tex_top;
    texture_coord++;

    texture_coord->x = tex_right;
    texture_coord->y = tex_bottom;
    texture_coord++;

    texture_coord->x = tex_left;
    texture_coord->y = tex_bottom;
}

// ----------------------------------------
static void write_colors(Color_i* color, Particle* particle)
{
    // Convert the color from float to int (1/4 the data size).
    Color_i color_base;
    color_base.red = particle->color.red * 255;
    color_base.green = particle->color.green * 255;
    color_base.blue = particle->color.blue * 255;
    color_base.alpha = particle->color.alpha * 255;

    *color = color_base;
    color++;
    *color = color_base;
    color++;
    *color = color_base;
    color++;
    *color = color_base;
}

// ----------------------------------------
// Draw all particles from first to last (inclusive).
static uint write_particles(ParticleEmitter *emitter, Particle* first, Particle* last,
                            const uint width, const uint height,
                            const float tex_left, const float tex_top,
                            const float tex_right, const float tex_bottom,
                            const uint first_particle_index)
{
    Color_i* color = &emitter->color_array[first_particle_index * VERTICES_IN_PARTICLE];
    Vertex2d* texture_coord = &emitter->texture_coord_array[first_particle_index * VERTICES_IN_PARTICLE];
    Vertex2d* vertex = &emitter->vertex_array[first_particle_index * VERTICES_IN_PARTICLE];

    int num_particles_drawn = 0;

    for(Particle* particle = first; particle <= last; particle++)
    {
        if(particle->time_to_live > 0)
        {
            write_colors(color, particle);
            write_texture_coords(texture_coord, tex_left, tex_top, tex_right, tex_bottom);
            write_particle_vertices(vertex, particle, width, height);

            color += VERTICES_IN_PARTICLE;
            texture_coord += VERTICES_IN_PARTICLE;
            vertex += VERTICES_IN_PARTICLE;

            num_particles_drawn++;
        }
    }

    return num_particles_drawn;
}

// --------------------------------------
static void update_vbo(ParticleEmitter* emitter, VALUE image)
{
    // Bind the image that we will be using throughout and get its coordinates.
    VALUE tex_info = rb_funcall(image, rb_intern("gl_tex_info"), 0);
    float tex_left   = NUM2DBL(rb_funcall(tex_info, rb_intern("left"), 0));
    float tex_right  = NUM2DBL(rb_funcall(tex_info, rb_intern("right"), 0));
    float tex_top    = NUM2DBL(rb_funcall(tex_info, rb_intern("top"), 0));
    float tex_bottom = NUM2DBL(rb_funcall(tex_info, rb_intern("bottom"), 0));

    // Pixel size of image.
    uint width  = NUM2UINT(rb_funcall(image, rb_intern("width"), 0));
    uint height = NUM2UINT(rb_funcall(image, rb_intern("height"), 0));

    // Ensure that drawing order is correct by drawing in order of creation...

    // First, we draw all those from the current, going up to the last one.
    Particle* first = &emitter->particles[emitter->next_particle_index];
    Particle* last = &emitter->particles[emitter->max_particles - 1];
    uint num_drawn = write_particles(emitter, first, last, width, height,
                                     tex_left, tex_top, tex_right, tex_bottom, 0);

    // Then go from the first to the current.
    first = emitter->particles;
    last = &emitter->particles[emitter->next_particle_index - 1];
    write_particles(emitter, first, last, width, height,
                    tex_left, tex_top, tex_right, tex_bottom, num_drawn);

    // Upload the data, but only as much as we are actually using.
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, emitter->vbo_id);
    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, emitter->color_array_offset,
                       sizeof(Color_f) * VERTICES_IN_PARTICLE * emitter->count, emitter->color_array);

    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, emitter->texture_coord_array_offset,
                       sizeof(Vertex2d) * VERTICES_IN_PARTICLE * emitter->count, emitter->texture_coord_array);

    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, emitter->vertex_array_offset,
                       sizeof(Vertex2d) * VERTICES_IN_PARTICLE * emitter->count, emitter->vertex_array);

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
}

// --------------------------------------
static void draw_vbo(ParticleEmitter* emitter, const uint texture_id)
{
    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture_id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
    // TODO: Work out whether it should be GL_LINEAR or GL_NEAREST.
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, emitter->vbo_id);

    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);

    glColorPointer(4, GL_UNSIGNED_BYTE, 0, (void*)emitter->color_array_offset);
    glTexCoordPointer(2, GL_FLOAT, 0, (void*)emitter->texture_coord_array_offset);
    glVertexPointer(2, GL_FLOAT, 0, (void*)emitter->vertex_array_offset);

    glDrawArrays(GL_QUADS, 0, emitter->count * VERTICES_IN_PARTICLE);

    glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
}

// ----------------------------------------
static VALUE draw_block(VALUE yield_value, VALUE self, int argc, VALUE argv[])
{
    EMITTER();

    VALUE shader = rb_iv_get(self, "@shader");
    VALUE image = rb_iv_get(self, "@image");

    if(!NIL_P(shader))
    {
        rb_funcall(shader, rb_intern("image="), 1, image);
        rb_funcall(shader, rb_intern("color="), 1, UINT2NUM(color_to_argb(&emitter->color)));
    }

    VALUE info = rb_funcall(image, rb_intern("gl_tex_info"), 0);
    VALUE tex_id = rb_funcall(info, rb_intern("tex_name"), 0);
    draw_vbo(emitter, FIX2UINT(tex_id));

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

    // Enable the shader, if provided.
    if(!NIL_P(shader)) rb_funcall(shader, rb_intern("enable"), 1, z);

    // Run the actual drawing operation at the correct Z-order.
    rb_block_call(window, rb_intern("gl"), 1, &z,
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
static void update_particle(ParticleEmitter* emitter, Particle* particle,
                            const float delta)
{
    // Apply friction
    particle->velocity_x *= 1.0 - particle->friction * delta;
    particle->velocity_y *= 1.0 - particle->friction * delta;

    // Gravity.
    particle->velocity_y += emitter->gravity * delta;

    // Move
    particle->x += particle->velocity_x * delta;
    particle->y += particle->velocity_y * delta;

    // Rotate.
    particle->angle += particle->angular_velocity * delta;

    // Resize.
    particle->scale += particle->zoom * delta;

    // Fade out.
    particle->color.alpha -= (particle->fade / 255.0) * delta;

    particle->time_to_live -= delta;

    // Die if out of time, invisible or shrunk to nothing.
    if((particle->time_to_live <= 0) ||
            (particle->color.alpha < 0) ||
            (particle->scale < 0))
    {
        particle->time_to_live = 0;
        emitter->count -= 1;
    }
}

// ----------------------------------------
// #update(delta)
VALUE Ashton_ParticleEmitter_update(VALUE self, VALUE delta)
{
    EMITTER();

    float _delta = NUM2DBL(delta);
    if(_delta < 0.0) rb_raise(rb_eArgError, "delta must be >= 0");

    if(emitter->count > 0)
    {
        Particle* particle = emitter->particles;
        Particle* last = &emitter->particles[emitter->max_particles - 1];
        for(; particle <= last; particle++)
        {
            // Ignore particles that are already dead.
            if(particle->time_to_live > 0)
            {
                update_particle(emitter, particle, _delta);
            }
        }
    }

    // Time to emit one (or more) new particles?
    emitter->time_until_emit -= _delta;
    while(emitter->time_until_emit <= 0)
    {
        rb_funcall(self, rb_intern("emit"), 0);
        emitter->time_until_emit += deviate(&emitter->interval);
    }

    // Copy all the current data onto the graphics card.
    if(emitter->count > 0)
    {
        VALUE image = rb_iv_get(self, "@image");
        update_vbo(emitter, image);
    }

    return Qnil;
}
