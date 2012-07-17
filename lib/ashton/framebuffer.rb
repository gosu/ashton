module Ashton
  class Framebuffer
    DEFAULT_DRAW_COLOR = Gosu::Color::WHITE

    attr_reader :width, :height
    def rendering?; @rendering end

    def initialize(width, height)
      @width, @height = width.to_i, height.to_i
      @fbo = create_framebuffer
      @texture = create_color_buffer
      @rendering = false

      status = glCheckFramebufferStatusEXT GL_FRAMEBUFFER_EXT
      raise unless status == GL_FRAMEBUFFER_COMPLETE_EXT

      clear

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0
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

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, @fbo unless rendering?

      glDisable GL_BLEND # Need to replace the alpha too.
      glClearColor *color
      glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
      glEnable GL_BLEND

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0 unless rendering?

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
      raise AshtonError if rendering?

      # Reset the projection matrix so that drawing into the buffer is zeroed.
      glPushMatrix
      glMatrixMode GL_PROJECTION
      glLoadIdentity
      glViewport 0, 0, $window.width, $window.height
      glOrtho 0, $window.width, $window.height, 0, -1, 1
      glTranslate 0, $window.height - height, 0

      $window.flush # Ensure that any drawing _before_ the render block is drawn to screen, rather than into the buffer.
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, @fbo
      @rendering = true
    end

    public
    def disable
      raise AshtonError unless rendering?

      $window.flush # Force all the drawing to draw now!
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, 0

      glPopMatrix
      @rendering = false
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
    # @option options :color [Gosu::Color] Color to apply to the drawing.
    def draw(x, y, z, options = {})
      options = {
          color: DEFAULT_DRAW_COLOR,
      }.merge! options
      shader = options[:shader]
      color = options[:color]

      shader.enable z if shader

      $window.gl z do
        if shader
          shader.color = color
          location = shader.send :uniform_location, "in_TextureEnabled", required: false
          shader.send :set_uniform, location, true if location != Shader::INVALID_LOCATION
        else
          glColor4f *color.to_opengl
        end

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
      # TODO: Just add a second colour buffer, rather than using a second fbo.
      unless defined? @fbo_flip
        @fbo_flip = create_framebuffer
        @fbo_flip_texture = create_color_buffer
      end

      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, @fbo_flip

      $window.gl do
        glColor4f 1.0, 1.0, 1.0, 1.0
        glMatrixMode GL_PROJECTION
        glLoadIdentity
        glViewport 0, 0, width, height
        glOrtho 0, width, height, 0, -1, 1

        glClearColor 0, 0, 0, 0
        glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
        draw 0, 0, nil
      end

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
    # Create the fbo itself and assign it for rendering.
    def create_framebuffer
      fbo = glGenFramebuffersEXT(1)[0]
      glBindFramebufferEXT GL_FRAMEBUFFER_EXT, fbo

      fbo
    end

    protected
    def create_color_buffer
      texture = glGenTextures(1)[0]
      glBindTexture GL_TEXTURE_2D, texture

      glTexParameterf GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE
      glTexParameterf GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE
      glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST
      glTexParameteri GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST

      # Create an empty texture, that might be filled with junk.
      glTexImage2D GL_TEXTURE_2D, 0, GL_RGBA8, @width, @height,
                   0, GL_RGBA, GL_UNSIGNED_BYTE, nil

      glFramebufferTexture2DEXT GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, texture, 0

      glBindTexture GL_TEXTURE_2D, 0 # Unbind the texture

      texture
    end

    protected
    def delete
      glDeleteFramebuffersEXT @fbo
      glDeleteTextures @texture

      glDeleteFramebuffersEXT @fbo_flip if defined? @fbo_flip
      glDeleteTextures @fbo_flip_texture if defined? @fbo_flip_texture
    end
  end
end