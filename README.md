Ashton
======

Description
-----------

Add extra visual effects to the Gosu game-development library, utilising OpenGL shaders (using shader model 1.0, for maximum compatibility) and frame-buffers.

"Ashton" is named after [Clark Ashton Smith](http://en.wikipedia.org/wiki/Clark_Ashton_Smith), an fantasy/horror author
with a particularly colourful imagination.

- Author: Bil Bas (Spooner)
- License: MIT

Usage
-----

    gem install ashton --pre

Features
--------

- Gosu::Color
  * #to_opengl - Converts to [1.0, 1.0, 1.0, 1.0] rgba format (as used by OpenGL).
  * .from_opengl - Creates new Color from [1.0, 1.0, 1.0, 1.0] rgba format (as used by OpenGL.

- Gosu::Image
  * #draw - Added :shader hash option to choose optional shader to use.
  * #draw_rot - Added :shader hash option to choose optional shader to use.
  * [TODO] #flip!, #flip, #mirror!, #mirror, #scale!, #scale, etc.
  * [TODO] #resize (Well, create another image which is smaller/larger).
  * [TODO] #to_framebuffer

- Gosu::Window
  * #post_process {} - Apply a shader (or shaders) to the contents of the block, after they have been drawn.
  * [TODO] #to_framebuffer - Copy the contents of the window as a {Ashton::Framebuffer}.
  * [TODO] #to_image - Create Gosu::Image from window contents.
  * [TODO] #draw_line - Added :shader hash option
  * [TODO] #draw_quad - Added :shader hash option
  * [TODO] #draw_triangle - Added :shader hash option

- {Ashton::Shader}
  * Wrapper around a GLSL shader program, which allows for complex, real-time, graphical manipulations.
  * #use {} - Inside the block, all draw operations are affected by the shader.
  * Supports vertex and fragment shaders.
  * Includes a small library of example shaders, which can be used to both affect individual draw actions or post-process the whole screen (:radial_blur, :pixelate, etc).

- {Ashton::Framebuffer}
  * A relatively low-level graphics buffer that can be drawn onto and drawn onto the Window.
  * #use {} - Inside the block, draw operations go into the framebuffer, rather than onto the window.
  * #to_image - Convert to Gosu::Image. 
  * #draw - Draw directly onto a Gosu::Window (Only accepts x, y coordinate).
  * [TODO] #flip!, #flip - Invert framebuffer's vertical orientation.

Limitations
-----------

Because of the way that Gosu and Ashton are _currently_ implemented, most Ashton activities will clear the draw buffer.
Thus, it is a good idea to make all your draws in Z-order yourself, rather than relying on Gosu to order them for you.

Similar Libraries
-----------------

- [TexPlay](https://github.com/banister/texplay) - Deals with Gosu::Image manipulation, such as per-pixel editing and drawing. It is compatible with, and complementary to, this gem.

Credits
-------

- Various trivial shaders - "randomly found on the Internet" :$

- (Classic and Simplex noise functions)[https://github.com/ashima/webgl-noise/] - Copyright (C) 2011 Ashima Arts - MIT license.
  * lib/ashton/shaders/include/classicnoise2D.glsl - 2D Classic Perlin noise implementation - `cnoise(vec2)`
  * lib/ashton/shaders/include/classicnoise3D.glsl - 3D Classic Perlin noise implementation - `cnoise(vec3)`
  * lib/ashton/shaders/include/classicnoise4D.glsl - 4D Classic Perlin noise implementation - `cnoise(vec4)`
  * lib/ashton/shaders/include/noise2D.glsl - 2D Simplex noise implementation - `snoise(vec2)`
  * lib/ashton/shaders/include/noise3D.glsl - 3D Simplex noise implementation - `snoise(vec3)`
  * lib/ashton/shaders/include/noise4D.glsl - 4D Simplex noise implementation - `snoise(vec4)`

- [Bloom filter by myheroics](http://myheroics.wordpress.com/2008/09/04/glsl-bloom-shader/)
  * lib/ashton/shaders/include/bloom.frag

- [Shockwave by Crystalin](http://empire-defense.crystalin.fr/blog/2d_shock_wave_texture_with_shader)
  * lib/ashton/shaders/include/shockwave.frag


