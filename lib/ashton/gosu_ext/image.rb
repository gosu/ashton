module Gosu
  class Image
    DEFAULT_DRAW_COLOR = Gosu::Color::WHITE

    alias_method :draw_without_hash, :draw
    protected :draw_without_hash
    def draw(*args)
      args, shader = if args.last.is_a?(Hash)
                       [args[0..-2], args.last[:shader]]
                     else
                       [args, nil]
                     end

      z = args[2]

      if shader
        shader.enable z
        $window.gl z do
          shader.image = self
          shader.color = args[5].is_a?(Color) ? args[5] : DEFAULT_DRAW_COLOR
        end
      end

      begin
        draw_without_hash(*args)
      ensure
        shader.disable z if shader
      end
    end

    alias_method :draw_rot_without_hash, :draw_rot
    protected :draw_rot_without_hash
    def draw_rot(*args)
      args, shader = if args.last.is_a?(Hash)
                       [args[0..-2], args.last[:shader]]
                     else
                       [args, nil]
                     end
      z = args[2]

      if shader
        shader.enable z
        $window.gl z do
          shader.image = self
          shader.color = args[8].is_a?(Color) ? args[8] : DEFAULT_DRAW_COLOR
        end
      end

      begin
        draw_rot_without_hash(*args)
      ensure
        shader.disable z if shader
      end
    end

    # Draw a list of centred sprites by position.
    #
    # @param points [Array<Array>] Array of [x, y] positions
    # @param z [Float] Z-order to draw - Ignored if shader is used.
    # @option options :scale [Float] (1.0) Relative size of the sprites
    # @option options :shader [Ashton::Shader] Shader to apply to all sprites.
    #
    # TODO: Need to use point sprites here, but this is still much faster than individual #draws if using shaders and comparable if not.
    def draw_as_points(points, z, options = {})
      color = options[:color] || DEFAULT_DRAW_COLOR
      scale = options[:scale] || 1.0
      shader = options[:shader]
      mode = options[:mode] || :default

      if shader
        shader.enable z
        $window.gl z do
          shader.image = self
          shader.color = color
        end
      end

      begin
        points.each do |x, y|
          draw_rot_without_hash x, y, z, 0, 0.5, 0.5, scale, scale, color, mode
        end
      ensure
        shader.disable z if shader
      end
    end

    # The cache is a replacement for Texplay's pixel cache system.
    def cache
      @cache ||= Ashton::PixelCache.new self
    end

    def to_texture
      Ashton::Texture.new self
    end
  end
end