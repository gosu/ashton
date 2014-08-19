module Ashton
  class Texture
    include Mixins::VersionChecking

    DEFAULT_DRAW_COLOR = Gosu::Color::WHITE
    VALID_DRAW_MODES = [:alpha_blend, :add, :multiply, :replace]

    class << self
      # [Boolean] Whether or not to pixelate (rather than smooth) on #draw
      attr_writer :pixelated
      # [Boolean] Whether or not to pixelate (rather than smooth) on #draw. Set true when Gosu::enable_undocumented_retrofication called.
      def pixelated?; @pixelated end
    end
    self.pixelated = false

    # [Boolean] Is this texture being rendered to currently?
    def rendering?; @rendering end

    # @overload initialize(image)
    #   Create a texture from a Gosu::Image
    #
    #   @see Image#to_texture
    #   @param image [Gosu::Image]
    #
    # @overload initialize(blob, width, height)
    #   Create a texture from a binary blob.
    #
    #   @param blob [String]
    #   @param width [Integer]
    #   @param height [Integer]
    #
    # @overload initialize(width, height)
    #   Create a blank (transparent) texture.
    #
    #   @param width [Integer]
    #   @param height [Integer]
    def initialize(*args)
      case args.size
        when 1
          # Create from Gosu::Image
          image = args[0]
          raise TypeError, "Expected Gosu::Image" unless image.is_a? Gosu::Image
          initialize_ image.width, image.height, nil

          render do
            # TODO: Ideally we'd draw the image in replacement mode, but Gosu doesn't support that.
            $window.gl do
              info = image.gl_tex_info
              Gl.glEnable Gl::GL_TEXTURE_2D
              Gl.glBindTexture Gl::GL_TEXTURE_2D, info.tex_name
              Gl.glEnable Gl::GL_BLEND
              Gl.glBlendFunc Gl::GL_ONE, Gl::GL_ZERO

              Gl.glBegin Gl::GL_QUADS do
                Gl.glTexCoord2d info.left, info.top
                Gl.glVertex2d 0, height # BL

                Gl.glTexCoord2d info.left, info.bottom
                Gl.glVertex2d 0, 0 # TL

                Gl.glTexCoord2d info.right, info.bottom
                Gl.glVertex2d width, 0 # TR

                Gl.glTexCoord2d info.right, info.top
                Gl.glVertex2d width, height # BR
              end
            end
          end

        when 2
          # Create blank image.
          width, height = *args
          initialize_ width, height, nil
          clear

        when 3
          # Create from blob - create a Gosu image first.
          blob, width, height = *args
          raise ArgumentError, "Blob data is not of expected size" if blob.length != width * height * 4
          initialize_ width, height, blob

        else
          raise ArgumentError, "Expected 1, 2 or 3 parameters."
      end

      @rendering = false
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

      Gl.glBindFramebufferEXT Gl::GL_FRAMEBUFFER_EXT, fbo_id unless rendering?

      Gl.glDisable Gl::GL_BLEND # Need to replace the alpha too.
      Gl.glClearColor(*color)
      Gl.glClear Gl::GL_COLOR_BUFFER_BIT | Gl::GL_DEPTH_BUFFER_BIT
      Gl.glEnable Gl::GL_BLEND

      Gl.glBindFramebufferEXT Gl::GL_FRAMEBUFFER_EXT, 0 unless rendering?

      nil
    end

    public
    # Enable the texture to use (e.g. to draw or convert it).
    def render
      raise ArgumentError, "Block required" unless block_given?
      raise Error, "Can't nest rendering" if rendering?

      $window.flush # Ensure that any drawing _before_ the render block is drawn to screen, rather than into the buffer.

      render_

      @rendering = true

      # Project onto the texture itself, using Gosu (inverted) coordinates.
      Gl.glPushMatrix
      Gl.glMatrixMode Gl::GL_PROJECTION
      Gl.glLoadIdentity
      Gl.glViewport 0, 0, width, height
      Gl.glOrtho 0, width, height, 0, -1, 1

      begin
        yield self
      ensure
        $window.flush # Force all the drawing to draw now!
        Gl.glBindFramebufferEXT Gl::GL_FRAMEBUFFER_EXT, 0

        @rendering = false

        Gl.glPopMatrix

        cache.refresh # Force lazy reloading of the cache.
      end

      self
    end

    # @!method draw(x, y, z, options = {})
    #   Draw the Texture.
    #
    #   This is not as versatile as converting the Texture into a Gosu::Image and then
    #   drawing it, but it is many times faster, so use it when you are updating the buffer
    #   every frame, rather than just composing an image.
    #
    #   Drawing in Gosu orientation will be flipped in standard OpenGL and visa versa.
    #
    #   @param x [Number] Top left corner x.
    #   @param y [Number] Top left corner y.
    #   @param z [Number] Z-order (can be nil to draw immediately)
    #
    #   @option options :shader [Ashton::Shader] Shader to apply to drawing.
    #   @option options :color [Gosu::Color] (Gosu::Color::WHITE) Color to apply to the drawing.
    #   @option options :mode [Symbol] (:alpha_blend) :alpha_blend, :add, :multiply, :replace
    #   @option options :multitexture [Texture] A texture to be used in a multi-texturing shader.
    #   @option options :pixelated [Boolean] (true if Gosu::enable_undocumented_retrofication ever called) Pixelate, rather than smooth, when zoomed out.

    public
    # Convert the current contents of the buffer into a Gosu::Image
    #
    # @option options :caching [Boolean] (true) TexPlay behaviour.
    # @option options :tileable [Boolean] (false) Standard Gosu behaviour.
    # @option options :rect [Array<Integer>] ([0, 0, width, height]) Rectangular area of buffer to use to create the image [x, y, w, h]
    def to_image(*args)
      cache.to_image(*args)
    end

    def dup
      # Create a new texture and draw self into it.
      new_texture = Texture.new width, height
      new_texture.render do
        draw 0, 0, 0, mode: :replace
      end
      new_texture
    end
  end
end