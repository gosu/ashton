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

    gem install ashton --pre

Features
--------

* Gosu extensions
    - {Gosu::Color} - Converting to and from opengl values.

    - {Gosu::Font} - Apply shader to draw operations.

    - {Gosu::Image} - Apply shader to each draw operation or group of draws. Manipulation, such as flipping and scaling.

    - {Gosu::Window} - Post-processing with shaders. Converting to image.

* Ashton
    - {Ashton::Framebuffer} - low-level graphics buffer that can be drawn directly onto and drawn to the Window.

    - {Ashton::ParticleEmitter} - Generates, manages and displays particles.

    - {Ashton::Shader} -  Wrapper around a GLSL shaders, Supports vertex and fragment shaders. Small shader/function library.

    - {Ashton::WindowBuffer} - Framebuffer that is the same size as the Gosu Window.

Requirements
------------

* OSX/Linux: Requires OpenGL library be installed.

Similar Libraries
-----------------

- [TexPlay](https://github.com/banister/texplay) - Deals with Gosu::Image manipulation, such as per-pixel editing and drawing. It is compatible with, and complementary to, this gem.

Third party
-----------

- OpenGL static library (in Windows binary gem) and headers.

- Various trivial shaders - "randomly found on the Internet" :$

- (Classic and Simplex noise functions)[https://github.com/ashima/webgl-noise/] - Copyright (C) 2011 Ashima Arts - MIT license.
  * classicnoise2D.glsl - 2D Classic Perlin noise implementation - `cnoise(vec2)`
  * classicnoise3D.glsl - 3D Classic Perlin noise implementation - `cnoise(vec3)`
  * classicnoise4D.glsl - 4D Classic Perlin noise implementation - `cnoise(vec4)`
  * noise2D.glsl - 2D Simplex noise implementation - `snoise(vec2)`
  * noise3D.glsl - 3D Simplex noise implementation - `snoise(vec3)`
  * noise4D.glsl - 4D Simplex noise implementation - `snoise(vec4)`

- [Bloom filter by myheroics](http://myheroics.wordpress.com/2008/09/04/glsl-bloom-shader/)
  * bloom.frag

- [Shockwave by Crystalin](http://empire-defense.crystalin.fr/blog/2d_shock_wave_texture_with_shader)
  * shockwave.frag

- [Radial Blur by gamerendering.com](http://www.gamerendering.com/2008/12/20/radial-blur-filter/)
  * radial_blur.frag


