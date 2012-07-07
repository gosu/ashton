module Ashton
  class Framebuffer
    attr_reader :width, :height

    def initialize(width, height)
      @width, @height = width.to_i, height.to_i
      @fbo, @fbo_texture = init_framebuffer
      #@fbo_depth = init_framebuffer_depth # Do we even need this for Gosu?

      status = glCheckFramebufferStatusEXT GL_FRAMEBUFFER_EXT
      raise unless status == GL_FRAMEBUFFER_COMPLETE_EXT

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0
      glBindRenderbufferEXT GL_RENDERBUFFER_EXT, 0
    end

    # Clears the buffer to transparent.
    def clear(options = {})
      options = {
          color: [0.0, 0.0, 0.0, 0.0],
      }.merge! options

      glClearColor *options[:color]
      glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
    end

    # Enable the framebuffer to use (e.g. to draw or convert it).
    def use
      raise ArgumentError, "block required" unless block_given?

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, @fbo
      result = yield self
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0

      result
    end

    # BUG: Draws inverted.
    def draw x, y
      glEnable GL_TEXTURE_2D
      glBindTexture GL_TEXTURE_2D, @fbo_texture

      glBegin GL_QUADS do
        glTexCoord2d 0, 1
        glVertex2d x, y + @height # BL

        glTexCoord2d 0, 0
        glVertex2d x, y # TL

        glTexCoord2d 1, 0
        glVertex2d x + @width, y # TR

        glTexCoord2d 1, 1
        glVertex2d x + @width, y + @height # BR
      end

      glBindTexture GL_TEXTURE_2D, 0
    end

    # Convert the current contents of the buffer into a Gosu::Image
    #
    #
    # @bug Image will be inverted (Maybe use a second buffer to turn it?).
    #
    # @option options [Boolean] :caching (true) TexPlay behaviour.
    # @option options [Boolean] :tileable (false) Standard Gosu behaviour.
    # @option options [Array<Integer>] :rect ([0, 0, width, height]) Rectangular area of buffer to use to create the image [x, y, w, h]
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
      draw 0, 0

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

    protected
    def init_framebuffer_depth
      fbo_depth = glGenRenderbuffersEXT(1)[0]
      glBindRenderbufferEXT GL_RENDERBUFFER_EXT, fbo_depth
      glRenderbufferStorageEXT GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24,
                               @width, @height

      glFramebufferRenderbufferEXT GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT,
                               GL_RENDERBUFFER_EXT, fbo_depth

      fbo_depth
    end

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
      glDeleteTextures @fbo_texture
      #glDeleteRenderbuffersEXT 1, @fbo_depth

      glDeleteFramebuffersEXT @fbo_flip if defined? @fbo_flip
      glDeleteTextures @fbo_flip_texture if defined? @fbo_flip_texture

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0
    end
  end
end