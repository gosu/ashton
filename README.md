Ashton
======

Usage
-----

    gem install ashton

Description
-----------

Add extra visual effects to the Gosu game-development library, utilising OpenGL shaders (using shader model 1.0, for maximum compatibility) and frame-buffers.

"Ashton" is named after [Clark Ashton Smith](http://en.wikipedia.org/wiki/Clark_Ashton_Smith), an fantasy/horror author
with a particularly colourful imagination.

Features
--------

- Gosu::Window
  * [TODO] #to_framebuffer - Copy the contents of the window as a Ashton::Framebuffer.
  * [TODO] #to_image - Create Gosu::Image from window contents.
  
- Gosu::Image
  * [TODO] #flip!, #mirror!, #scale!, etc.
  * [TODO] #resize (Well, create another image which is smaller/larger).

- Ashton::Shader
  * #postprocess - Used to post-process the entire Gosu::Window at once, after some, or all, drawing is complete.
  * #use - Inside the block, draw operations are affected by the shader (#use { ...draw operations... } )
  * Supports vertex and fragment shaders.
  * [TODO] Includes a small library of example shaders (:blur, :simplex, etc).
  
- Ashtons::Framebuffer
  * #use - Inside the block, draw operations go into the Framebuffer, rather than onto the window.
  * #to_image - Convert to Gosu::Image. 
  * #draw - Draw directly onto Gosu::Window.
  * [TODO] #flip! - Invert Framebuffer's vertical orientation.
  
Similar Libraries
-----------------

- [TexPlay](https://github.com/banister/texplay) 
  * Deals with Gosu::Image manipulation, such as per-pixel editing and drawing. It is compatible with, and complementary to, this gem.
  

