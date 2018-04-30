Ashton
======

Description
-----------

Add extra visual effects to the Gosu game-development library, utilising OpenGL shaders (using shader model 1.0, for maximum compatibility) and frame-buffers.

"Ashton" is named after [Clark Ashton Smith](http://en.wikipedia.org/wiki/Clark_Ashton_Smith), an fantasy/horror author
with a particularly colourful imagination.

- Author: [Bil Bas (Spooner)](http://spooner.github.com/)
- [Wiki](https://github.com/Spooner/ashton/wiki)
- License: MIT

Usage
-----

    gem install ashton

Features
--------

* Gosu extensions
    - {Gosu::Color} - Converting to and from opengl values.

    - {Gosu::Font} - Apply shader to draw operations.

    - {Gosu::Image} - Apply shader to each draw operation or group of draws. Manipulation, such as flipping and scaling.

    - {Gosu::Window} - Post-processing with shaders. Converting to image.

* Ashton
    - {Ashton::Texture} - Single texture (compared to Gosu::Image which uses a spritesheet) which can be drawn directly onto and drawn to the Window.

    - {Ashton::Lighting::Manager} -  Manages and combines the lighting from {Ashton::Lighting::LightSource} objects.

    - {Ashton::Lighting::LightSource} -  A single light-source that illuminates and whose can be blocked by shadow-casting objects.

    - {Ashton::ParticleEmitter} - Generates, manages and displays particles.

    - {Ashton::PixelCache} - Cached image data attached to an {Ashton::Texture} or {Gosu::Image}.

    - {Ashton::SignedDistanceField} - A signed distance field based on a an image mask.

    - {Ashton::Shader} -  Wrapper around a GLSL shaders, Supports vertex and fragment shaders. Small shader/function library.

    - {Ashton::WindowBuffer} - Texture that is the same size as the Gosu Window that can capture the contents of the screen.

Requirements
------------

* OSX/Linux: Requires OpenGL library be installed.

* {Ashton::Shader} and {Ashton::Lighting} or anything else using shaders, require OpenGL 2.0.

Similar Libraries
-----------------

- [TexPlay](https://github.com/banister/texplay) - Deals with Gosu::Image manipulation, such as per-pixel editing and drawing. It is compatible with, and complementary to, this gem.

Third party
-----------

- OpenGL static library (in Windows binary gem) and headers.
- [GLee](http://elf-stone.com/glee.php) source.

- Various trivial shaders - "randomly found on the Internet" :$

- [Classic and Simplex noise functions](https://github.com/ashima/webgl-noise/) - Copyright (C) 2011 Ashima Arts - MIT license.
  * classicnoise2d.glsl - 2D Classic Perlin noise implementation - `cnoise(vec2)`
  * classicnoise3d.glsl - 3D Classic Perlin noise implementation - `cnoise(vec3)`
  * classicnoise4d.glsl - 4D Classic Perlin noise implementation - `cnoise(vec4)`
  * noise2d.glsl - 2D Simplex noise implementation - `snoise(vec2)`
  * noise3d.glsl - 3D Simplex noise implementation - `snoise(vec3)`
  * noise4d.glsl - 4D Simplex noise implementation - `snoise(vec4)`

- [Bloom filter by myheroics](http://myheroics.wordpress.com/2008/09/04/glsl-bloom-shader/)
  * bloom.frag

- [Shockwave by Crystalin](http://empire-defense.crystalin.fr/blog/2d_shock_wave_texture_with_shader)
  * shockwave.frag

- [Radial Blur by gamerendering.com](http://www.gamerendering.com/2008/12/20/radial-blur-filter/)
  * radial_blur.frag

- Lighting based on, but much optimised from, Catalin Zima's shader based dynamic shadows system.
  * http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/
  * {Ashton::Lighting::LightSource} and {Ashton::Lighting::Manager} classes.
  * shadow_blur.frag
  * shadow_distory.frag
  * shadow_draw_shadows.frag



