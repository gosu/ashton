#include "particle_emitter.h"

// Helpers.
inline static float randf();
inline static float deviate(Range * range);
static bool color_changes(ParticleEmitter* emitter);
static bool texture_changes(ParticleEmitter* emitter);

static void update_particle(ParticleEmitter* emitter, Particle* particle, const float delta);
static void update_vbo(ParticleEmitter* emitter);
static void draw_vbo(ParticleEmitter* emitter);

static Vertex2d* write_particle_vertices(Vertex2d* vertex,
                                         Particle* particle,
                                         const uint width, const uint height);
static uint write_vertices_for_particles(Vertex2d* vertex,
                                         Particle* first, Particle* last,
                                         const uint width, const uint height);

static Vertex2d* write_particle_texture_coords(Vertex2d* texture_coord,
                                               TextureInfo* texture_info);
static void write_texture_coords_for_particles(Vertex2d* texture_coord,
                                               Particle* first, Particle* last,
                                               TextureInfo* texture_info);
static void write_texture_coords_for_all_particles(Vertex2d *texture_coord,
                                                   TextureInfo* texture_info,
                                                   const uint num_particles);

static Color_i* write_particle_colors(Color_i* color_out, Color_f* color_in);
static void write_colors_for_particles(Color_i* color,
                                       Particle* first, Particle* last);

static uint color_to_argb(Color_f* color);

static void init_vbo(ParticleEmitter* emitter);
static VALUE particle_emitter_allocate(VALUE klass);
static void particle_emitter_mark(ParticleEmitter* emitter);
static void particle_emitter_free(ParticleEmitter* emitter);


// === GETTERS & SETTERS ===
GET_SET_EMITTER_DATA(x, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA(y, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA(z, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA(gravity, rb_float_new, (float)NUM2DBL);

GET_SET_EMITTER_DATA_RANGE(center_x, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(center_y, rb_float_new, (float)NUM2DBL);

GET_SET_EMITTER_DATA_RANGE(angular_velocity, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(fade, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(friction, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(offset, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(scale, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(speed, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(time_to_live, rb_float_new, (float)NUM2DBL);
GET_SET_EMITTER_DATA_RANGE(zoom, rb_float_new, (float)NUM2DBL);

GET_EMITTER_DATA(max_particles, max_particles, UINT2NUM);
GET_EMITTER_DATA(count, count, UINT2NUM);

// Special case of interval, since that should also alter the time until emission.

//
VALUE Ashton_ParticleEmitter_set_interval_min(VALUE self, VALUE value)
{
    EMITTER();
    emitter->interval.min = (float)NUM2DBL(value);
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
    emitter->interval.max = (float)NUM2DBL(value);
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

    rb_define_protected_method(rb_cParticleEmitter, "shader", Ashton_ParticleEmitter_get_shader, 0);
    rb_define_protected_method(rb_cParticleEmitter, "shader=", Ashton_ParticleEmitter_set_shader, 1);

    rb_define_protected_method(rb_cParticleEmitter, "image", Ashton_ParticleEmitter_get_image, 0);
    rb_define_protected_method(rb_cParticleEmitter, "image=", Ashton_ParticleEmitter_set_image, 1);
}

// ----------------------------------------
// Ashton::ParticleEmitter#initialize
VALUE Ashton_ParticleEmitter_init(VALUE self, VALUE x, VALUE y, VALUE z, VALUE max_particles)
{
    EMITTER();

    emitter->x = (float)NUM2DBL(x);
    emitter->y = (float)NUM2DBL(y);
    emitter->z = (float)NUM2DBL(z);

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

    emitter->texture_coords_array = ALLOC_N(Vertex2d, num_vertices);
    emitter->texture_coords_array_offset = sizeof(Color_i) * num_vertices;

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

// ----------------------------------------
VALUE Ashton_ParticleEmitter_set_shader(VALUE self, VALUE shader)
{
    EMITTER();
    emitter->rb_shader = shader;
    return shader;
}

// ----------------------------------------
VALUE Ashton_ParticleEmitter_get_shader(VALUE self)
{
    EMITTER();
    return emitter->rb_shader;
}

// ----------------------------------------
VALUE Ashton_ParticleEmitter_get_image(VALUE self)
{
    EMITTER();
    return emitter->rb_image;
}

// ----------------------------------------
// Update the texture coordinates when a new image is chosen.
VALUE Ashton_ParticleEmitter_set_image(VALUE self, VALUE image)
{
    EMITTER();

    emitter->rb_image = image;

    // Pixel size of image.
    emitter->width = NUM2UINT(rb_funcall(image, rb_intern("width"), 0));
    emitter->height = NUM2UINT(rb_funcall(image, rb_intern("height"), 0));

    // Fill the array with all the same coords (won't be used if the image changes dynamically).
    VALUE tex_info = rb_funcall(image, rb_intern("gl_tex_info"), 0);
    emitter->texture_info.id     = FIX2UINT(rb_funcall(tex_info, rb_intern("tex_name"), 0));
    emitter->texture_info.left   = (float)NUM2DBL(rb_funcall(tex_info, rb_intern("left"), 0));
    emitter->texture_info.right  = (float)NUM2DBL(rb_funcall(tex_info, rb_intern("right"), 0));
    emitter->texture_info.top    = (float)NUM2DBL(rb_funcall(tex_info, rb_intern("top"), 0));
    emitter->texture_info.bottom = (float)NUM2DBL(rb_funcall(tex_info, rb_intern("bottom"), 0));

    write_texture_coords_for_all_particles(emitter->texture_coords_array,
                                           &emitter->texture_info,
                                           emitter->max_particles);

    // Push whole array to graphics card.
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, emitter->vbo_id);

    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, emitter->texture_coords_array_offset,
                       sizeof(Vertex2d) * VERTICES_IN_PARTICLE * emitter->max_particles,
                       emitter->texture_coords_array);

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);

    return image;
}

// ----------------------------------------
static VALUE particle_emitter_allocate(VALUE klass)
{
    ParticleEmitter* emitter = ALLOC(ParticleEmitter);
    memset(emitter, 0, sizeof(ParticleEmitter));

    return Data_Wrap_Struct(klass, particle_emitter_mark, particle_emitter_free, emitter);
}

// ----------------------------------------
static void particle_emitter_mark(ParticleEmitter* emitter)
{
    if(!NIL_P(emitter->rb_shader)) rb_gc_mark(emitter->rb_shader);
    rb_gc_mark(emitter->rb_image);
}

// ----------------------------------------
// Deallocate data structure and its contents.
static void particle_emitter_free(ParticleEmitter* emitter)
{
    glDeleteBuffersARB(1, &emitter->vbo_id);
    xfree(emitter->color_array);
    xfree(emitter->texture_coords_array);
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
    if(isfinite(range->min) && isfinite(range->max))
    {
        float deviation = (range->max - range->min) / 2.0;
        return range->min + deviation + randf() * deviation - randf() * deviation;
    }
    else
    {
        return range->max;
    }
}

// ----------------------------------------
static Vertex2d* write_particle_vertices(Vertex2d* vertex, Particle* particle,
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
    vertex++;

    return vertex;
}

// ----------------------------------------
// Calculate the vertices for all active particles
static uint write_vertices_for_particles(Vertex2d *vertex,
                                         Particle* first, Particle* last,
                                         const uint width, const uint height)
{
    int num_particles_written = 0;

    for(Particle* particle = first; particle <= last; particle++)
    {
        if(particle->time_to_live > 0)
        {
            vertex = write_particle_vertices(vertex, particle, width, height);
            num_particles_written++;
        }
    }

    return num_particles_written;
}

// ----------------------------------------
static Vertex2d* write_particle_texture_coords(Vertex2d* texture_coord,
                                               TextureInfo* texture_info)
{
    texture_coord->x = texture_info->left;
    texture_coord->y = texture_info->top;
    texture_coord++;

    texture_coord->x = texture_info->right;
    texture_coord->y = texture_info->top;
    texture_coord++;

    texture_coord->x = texture_info->right;
    texture_coord->y = texture_info->bottom;
    texture_coord++;

    texture_coord->x = texture_info->left;
    texture_coord->y = texture_info->bottom;
    texture_coord++;

    return texture_coord;
}

// ----------------------------------------
// Write out texture coords, assuming image is animated.
static void write_texture_coords_for_particles(Vertex2d *texture_coord,
                                               Particle* first, Particle* last,
                                               TextureInfo * texture_info)
{
    for(Particle* particle = first; particle <= last; particle++)
    {
        if(particle->time_to_live > 0)
        {
            texture_coord = write_particle_texture_coords(texture_coord, texture_info);
        }
    }
}

// ----------------------------------------
// Write all texture coords, assuming the image isn't animated.
static void write_texture_coords_for_all_particles(Vertex2d *texture_coord,
                                                   TextureInfo * texture_info,
                                                   const uint num_particles)
{
    for(uint i = 0; i < num_particles; i++)
    {
        texture_coord = write_particle_texture_coords(texture_coord, texture_info);
    }
}

// ----------------------------------------
static Color_i* write_particle_colors(Color_i* color_out, Color_f* color_in)
{
    // Convert the color from float to int (1/4 the data size).
    Color_i color;
    color.red = color_in->red * 255;
    color.green = color_in->green * 255;
    color.blue = color_in->blue * 255;
    color.alpha = color_in->alpha * 255;

    *color_out = color;
    color_out++;
    *color_out = color;
    color_out++;
    *color_out = color;
    color_out++;
    *color_out = color;
    color_out++;

    return color_out;
}

// ----------------------------------------
static void write_colors_for_particles(Color_i *color,
                                       Particle* first, Particle* last)
{
    for(Particle* particle = first; particle <= last; particle++)
    {
        if(particle->time_to_live > 0)
        {
            color = write_particle_colors(color, &particle->color);
        }
    }
}

// --------------------------------------
// Is the colour animated (e.g. is fade set)?
static bool color_changes(ParticleEmitter* emitter)
{
   return ((emitter->fade.min != 0.0) || (emitter->fade.max != 0.0));
}

// --------------------------------------
// Is the texture animated?
static bool texture_changes(ParticleEmitter* emitter)
{
   return false;
}

// --------------------------------------
static void update_vbo(ParticleEmitter* emitter)
{
    // Ensure that drawing order is correct by drawing in order of creation...

    // First, we draw all those from after the current, going up to the last one.
    Particle* first = &emitter->particles[emitter->next_particle_index];
    Particle* last = &emitter->particles[emitter->max_particles - 1];
    if(color_changes(emitter))
    {
        write_colors_for_particles(emitter->color_array,
                                   first, last);
    }
    if(texture_changes(emitter))
    {
        write_texture_coords_for_particles(emitter->texture_coords_array,
                                           first, last,
                                           &emitter->texture_info);
    }
    uint num_particles_written = write_vertices_for_particles(emitter->vertex_array,
                                                              first, last,
                                                              emitter->width, emitter->height);
    // When we copy the second half of the particles, we want to start writing further on.
    uint offset = num_particles_written * VERTICES_IN_PARTICLE;

    // Then go from the first to the current.
    first = emitter->particles;
    last = &emitter->particles[emitter->next_particle_index - 1];
    if(color_changes(emitter))
    {
        write_colors_for_particles(&emitter->color_array[offset],
                                   first, last);
    }

    if(texture_changes(emitter))
    {
        write_texture_coords_for_particles(&emitter->texture_coords_array[offset],
                                           first, last,
                                           &emitter->texture_info);
    }

    write_vertices_for_particles(&emitter->vertex_array[offset],
                                 first, last,
                                 emitter->width, emitter->height);

    // Upload the data, but only as much as we are actually using.
    glBindBufferARB(GL_ARRAY_BUFFER_ARB, emitter->vbo_id);
    if(color_changes(emitter))
    {
        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, emitter->color_array_offset,
                           sizeof(Color_i) * VERTICES_IN_PARTICLE * emitter->count,
                           emitter->color_array);
    }

    if(texture_changes(emitter))
    {
        glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, emitter->texture_coords_array_offset,
                           sizeof(Vertex2d) * VERTICES_IN_PARTICLE * emitter->count,
                           emitter->texture_coords_array);
    }

    glBufferSubDataARB(GL_ARRAY_BUFFER_ARB, emitter->vertex_array_offset,
                       sizeof(Vertex2d) * VERTICES_IN_PARTICLE * emitter->count,
                       emitter->vertex_array);

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
}

// --------------------------------------
static void draw_vbo(ParticleEmitter* emitter)
{
    glEnable(GL_BLEND);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, emitter->texture_info.id);

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, emitter->vbo_id);

    // Only use colour array if colours are dynamic. Otherwise a single colour setting is enough.
    if(color_changes(emitter))
    {
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, (void*)emitter->color_array_offset);
    }
    else
    {
        glColor4fv((GLfloat*)&emitter->color);
    }

    // Always use the texture array, even if it is static.
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, (void*)emitter->texture_coords_array_offset);

    // Vertex array will always be dynamic.
    glEnableClientState(GL_VERTEX_ARRAY);
    glVertexPointer(2, GL_FLOAT, 0, (void*)emitter->vertex_array_offset);

    glDrawArrays(GL_QUADS, 0, emitter->count * VERTICES_IN_PARTICLE);

    if(color_changes(emitter)) glDisableClientState(GL_COLOR_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);

    glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
}

// ----------------------------------------
static VALUE draw_block(VALUE yield_value, VALUE self, int argc, VALUE argv[])
{
    EMITTER();

    if(!NIL_P(emitter->rb_shader))
    {
        rb_funcall(emitter->rb_shader, rb_intern("image="), 1, emitter->rb_image);
        rb_funcall(emitter->rb_shader, rb_intern("color="), 1, UINT2NUM(color_to_argb(&emitter->color)));
    }

    draw_vbo(emitter);

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
    VALUE z = rb_float_new(emitter->z);

    // Enable the shader, if provided.
    if(!NIL_P(emitter->rb_shader)) rb_funcall(emitter->rb_shader, rb_intern("enable"), 1, z);

    // Run the actual drawing operation at the correct Z-order.
    rb_block_call(window, rb_intern("gl"), 1, &z,
                  RUBY_METHOD_FUNC(draw_block), self);

    // Disable the shader, if provided.
    if(!NIL_P(emitter->rb_shader)) rb_funcall(emitter->rb_shader, rb_intern("disable"), 1, z);

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
    particle->x = emitter->x + fast_sin_deg(position_angle) * offset;
    particle->y = emitter->y + fast_cos_deg(position_angle) * offset;
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

    float _delta = (float)NUM2DBL(delta);
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
    if(emitter->count > 0) update_vbo(emitter);

    return Qnil;
}
