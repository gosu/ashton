module Ashton
  class LightSource
    include Mixins::VersionChecking

    # PIXEL_BUFFER_EXTENSION = "GL_EXT_pixel_buffer_object"

    attr_reader :radius
    attr_accessor :x, :y, :z, :color

    def width; @radius * 2 end
    def height; @radius * 2 end

    def initialize(x, y, z, radius, options = {})
      #check_opengl_extension PIXEL_BUFFER_EXTENSION

      @x, @y, @z, @radius = x, y, z, radius.to_i
      @color = options[:color] || Gosu::Color::WHITE

      @shadow_casters_fb = Ashton::Framebuffer.new width, height
      @shadow_map_fb = Ashton::Framebuffer.new 2, height
      @shadows_fb = Ashton::Framebuffer.new width, height
      @blurred_fb = Ashton::Framebuffer.new width, height

      load_shaders
    end

    public
    # Only need to render shadows again if anything has actually changed!
    def render_shadows
      raise "block required" unless block_given?

      # Get a copy of the shadow-casting objects in out light-zone.
      @shadow_casters_fb.render do |buffer|
        buffer.clear
        $window.translate @radius - @x, @radius - @y do
          yield
        end
      end

      # Distort the shadow casters and reduce into a a 2-pixel wide shadow-map of the blockages.
      @shadow_map_fb.render do
        $window.scale 1.0 / radius, 1 do
          @shadow_casters_fb.draw 0, 0, 0, shader: @distort
        end
      end

      # This will be the shadow map texture passed into @draw_shadows
      glActiveTexture GL_TEXTURE1
      raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE1
      glBindTexture GL_TEXTURE_2D, @shadow_map_fb.instance_variable_get(:@texture)

      # And go back to the default texture for general work.
      glActiveTexture GL_TEXTURE0

      # Render the shadows themselves, before blurring.
      @shadows_fb.render do
        @shadow_casters_fb.draw 0, 0, 0, shader: @draw_shadows
      end

      # Finally blur it up and apply the radial lighting.
      @blurred_fb.render do
        @shadows_fb.draw 0, 0, 0, shader: @blur
      end

      unless defined? @saved
        @saved = true
        return unless @x == 240 or @x == 400
        # Only save once. for purposes of this example only.
        @shadow_casters_fb.to_image.save "output/shadow_casters_#{x}.png"
        @shadow_map_fb.to_image.save "output/shadow_map_#{x}.png"
        @shadows_fb.to_image.save "output/shadows_#{x}.png"
        @blurred_fb.to_image.save "output/blurred_#{x}.png"
      end

      nil
    end

    public
    def draw(options = {})
      options = {
          blend: :add,
          color: @color,
      }.merge! options

      @blurred_fb.draw @x - @radius, @y - @radius, @z, options
      @shadow_casters_fb.draw @x - @radius, @y - @radius, @z, options
      nil
    end

    public
    # Draw some quadrant lines (for debugging).
    def draw_debug
      color = @color.dup
      color.alpha = 75

      $window.translate -@radius, -@radius do
        $window.draw_line x, y, color, x + width, y, color, z
        $window.draw_line x + width, y, color, x + width, y + height, color, z
        $window.draw_line x + width, y + height, color, x, y + height, color, z
        $window.draw_line x, y + height, color, x, y, color, z

        $window.draw_line x, y, color, x + width, y + height, color, z
        $window.draw_line x, y + height, color, x + width, y, color, z
      end
    end

    protected
    def load_shaders
      @distort = Ashton::Shader.new fragment: :shadow_distort,
                                    uniforms: {
                                        texture_width: width,
                                    }

      @draw_shadows = Ashton::Shader.new fragment: :shadow_draw_shadows,
                                         uniforms: {
                                             shadow_map_texture: 1,
                                             texture_width: width,
                                         }

      @blur = Ashton::Shader.new fragment: :shadow_blur,
                                 uniforms: {
                                     texture_width: width,
                                 }

      nil
    end
  end
end