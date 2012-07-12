module Ashton
  class Framebuffer
    attr_reader :width, :height

    def initialize(width, height)
      @width, @height = width.to_i, height.to_i
      @fbo, @texture = init_framebuffer

      status = glCheckFramebufferStatusEXT GL_FRAMEBUFFER_EXT
      raise unless status == GL_FRAMEBUFFER_COMPLETE_EXT

      clear

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0
      glBindRenderbufferEXT GL_RENDERBUFFER_EXT, 0
    end

    public
    # Clears the buffer, optionally to a specific color.
    #
    # @option options :color [Gosu::Color, Array<Float>] (transparent)
    def clear(options = {})
      options = {
          color: [0.0, 0.0, 0.0, 0.0],
      }.merge! options

      color = options[:color]
      color = color.to_opengl if color.is_a? Gosu::Color

      $window.gl do
        glBindFramebufferEXT GL_FRAMEBUFFER_EXT, @fbo
        glBindRenderbufferEXT GL_RENDERBUFFER_EXT, @texture

        glDisable GL_BLEND # Need to replace the alpha too.
        glClearColor *color
        glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
      end

      nil
    end

    public
    # Enable the framebuffer to use (e.g. to draw or convert it).
    def render
      raise ArgumentError, "block required (use #enable/#disable without blocks)" unless block_given?

      enable
      begin
        result = yield self
      ensure
        disable
      end

      result
    end

    public
    def enable
      $window.flush # Ensure that any drawing _before_ the render block is drawn to screen, rather than into the buffer.
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, @fbo
    end

    public
    def disable
      $window.flush # Force all the drawing to draw now!
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0
    end

    public
    # Draw the image, _immediately_ (no z-ordering by Gosu).
    #
    # This is not as versatile as converting the Framebuffer into a Gosu::Image and then
    # drawing it, but it is many times faster, so use it when you are updating the buffer
    # every frame, rather than just composing an image.
    #
    # Drawing in Gosu orientation will be flipped in standard OpenGL and visa versa.
    #
    # @param x [Number] Top left corner
    # @param y [Number] Top right corner
    # @option options :shader [Ashton::Shader] Shader to apply to drawing.
    def draw(x, y, z, options = {})
      shader = options[:shader]

      shader.enable z if shader

      $window.gl z do
        #shader.color = options[:color]
        location = shader.send :uniform_location, "in_TextureEnabled", required: false
        shader.send :set_uniform, location, true if location != Shader::INVALID_LOCATION

        glEnable GL_BLEND
        glEnable GL_TEXTURE_2D
        glActiveTexture GL_TEXTURE0
        glBindTexture GL_TEXTURE_2D, @texture

        glBegin GL_QUADS do
          glTexCoord2d 0, 0
          glVertex2d x, y + @height # BL

          glTexCoord2d 0, 1
          glVertex2d x, y # TL

          glTexCoord2d 1, 1
          glVertex2d x + @width, y # TR

          glTexCoord2d 1, 0
          glVertex2d x + @width, y + @height # BR
        end
      end

      shader.disable z if shader
    end

    public
    # Convert the current contents of the buffer into a Gosu::Image
    #
    # @option options :caching [Boolean] (true) TexPlay behaviour.
    # @option options :tileable [Boolean] (false) Standard Gosu behaviour.
    # @option options :rect [Array<Integer>] ([0, 0, width, height]) Rectangular area of buffer to use to create the image [x, y, w, h]
    def to_image(options = {})
      options = {
        rect: [0, 0, @width, @height],
        tileable: false,
      }.merge! options

      rect = options[:rect]

      # Draw onto the clean flip buffer, in order to flip before saving.
      @fbo_flip, @fbo_flip_texture = init_framebuffer unless defined? @fbo_flip

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, @fbo_flip
      glClearColor 0, 0, 0, 0
      glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
      draw 0, 0, nil

      # Read the data in the flip-buffer.
      glBindTexture GL_TEXTURE_2D, @fbo_flip_texture
      blob = glReadPixels *rect, GL_RGBA, GL_UNSIGNED_BYTE

      # Clean up.
      glBindTexture GL_TEXTURE_2D, 0
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0

      # Create a new Image from the flipped pixel data.
      stub = ImageStub.new blob, rect[2], rect[3]
      if defined? TexPlay
        Gosu::Image.new $window, stub, options[:tileable], options
      else
        Gosu::Image.new $window, stub, options[:tileable]
      end

    end

    public
    # Copy the window contents into the buffer.
    def capture_window
      glBindTexture GL_TEXTURE_2D, @texture
      glCopyTexImage2D GL_TEXTURE_2D, 0, GL_RGBA8, 0, 0, width, height, 0
    end

    protected
    # Create an fbo and its texture
    def init_framebuffer
      fbo = glGenFramebuffersEXT(1)[0]
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, fbo

      texture = init_framebuffer_texture

      glFramebufferTexture2DEXT GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texture, 0

      [fbo, texture]
    end

    protected
    # Called by init_framebuffer.
    def init_framebuffer_texture
      texture = glGenTextures(1)[0]
      glBindTexture GL_TEXTURE_2D, texture

      glTexParameterf GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
      glTexParameterf GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
      glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
      glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST

      glTexImage2D GL_TEXTURE_2D, 0, GL_RGBA8, @width, @height,
                   0, GL_RGBA, GL_UNSIGNED_BYTE, nil

      glBindTexture GL_TEXTURE_2D, 0 # Unbind the texture

      texture
    end

    protected
    def delete
      glDeleteFramebuffersEXT @fbo
      glDeleteTextures @texture

      glDeleteFramebuffersEXT @fbo_flip if defined? @fbo_flip
      glDeleteTextures @fbo_flip_texture if defined? @fbo_flip_texture

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0
    end
  end
end