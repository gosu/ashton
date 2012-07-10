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

- Gosu::Font
  * [TODO] #draw - Added :shader hash option to choose optional shader to use.
  * [TODO] #draw_rel - Added :shader hash option to choose optional shader to use.

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
  * #use {} - Inside the block, all draw operations are affected by the shader.
  * Supports vertex and fragment shaders.
  * Includes a small library of example shaders (:radial_blur, :pixelate, etc).

- {Ashton::Framebuffer}
  * #use {} - Inside the block, draw operations go into the framebuffer, rather than onto the window.
  * #to_image - Convert to Gosu::Image. 
  * #draw - Draw directly onto a Gosu::Window (Only accepts x, y coordinate).
  * [TODO] #flip!, #flip - Invert framebuffer's vertical orientation.
  
Similar Libraries
-----------------

- [TexPlay](https://github.com/banister/texplay) - Deals with Gosu::Image manipulation, such as per-pixel editing and drawing. It is compatible with, and complementary to, this gem.

Credits
-------

- simplex.glsl - simplex noise implementation - Copyright (C) 2011 Ashima Arts - MIT license.
  

