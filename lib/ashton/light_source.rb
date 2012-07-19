module Ashton
  # Based on Catalin Zima's shader based dynamic shadows system.
  # http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/
  class LightSource
    include Mixins::VersionChecking

    # PIXEL_BUFFER_EXTENSION = "GL_EXT_pixel_buffer_object"

    class << self
      attr_accessor :distort_shader, :draw_shadows_shader, :blur_shader
    end

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
    def render_shadows(&block)
      raise "block required" unless block_given?

      render_shadow_casters &block

      # Distort the shadow casters and reduce into a a 2-pixel wide shadow-map of the blockages.
      LightSource.distort_shader.use { distort }

      # Render the shadows themselves, before blurring.
      LightSource.draw_shadows_shader.use { draw_shadows }

      # Finally blur it up and apply the radial lighting.
      LightSource.blur_shader.use { blur }

      nil
    end

    protected
    def render_shadow_casters
      raise "block required" unless block_given?
      # Get a copy of the shadow-casting objects in out light-zone.
      @shadow_casters_fb.render do |buffer|
        buffer.clear
        $window.translate @radius - @x, @radius - @y do
          yield
        end
      end
    end

    protected
    def distort
      LightSource.distort_shader.texture_width = width
      @shadow_map_fb.render do
        $window.scale 1.0 / radius, 1 do
          @shadow_casters_fb.draw 0, 0, 0
        end
      end
    end

    protected
    def draw_shadows
      LightSource.draw_shadows_shader.texture_width = width
      @shadows_fb.render do
        # Not actually drawing anything from the shadow map buffer.
        # It is just a data input to what will be drawn.
        $window.scale radius, 1 do
          @shadow_map_fb.draw 0, 0, 0
        end
      end
    end

    protected
    def blur
      LightSource.blur_shader.texture_width = width
      @blurred_fb.render do
        @shadows_fb.draw 0, 0, 0
      end
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
      LightSource.distort_shader ||= Ashton::Shader.new fragment: :shadow_distort

      LightSource.draw_shadows_shader ||= Ashton::Shader.new fragment: :shadow_draw_shadows

      LightSource.blur_shader ||= Ashton::Shader.new fragment: :shadow_blur

      nil
    end

    protected
    # Used for debugging purposes only.
    def save_buffers
      # Only save once. for purposes of this example only.
      @shadow_casters_fb.to_image.save "output/shadow_casters_#{x}_#{y}.png"
      @shadow_map_fb.to_image.save "output/shadow_map_#{x}_#{y}.png"
      @shadows_fb.to_image.save "output/shadows_#{x}_#{y}.png"
      @blurred_fb.to_image.save "output/blurred_#{x}_#{y}.png"
    end
  end
end