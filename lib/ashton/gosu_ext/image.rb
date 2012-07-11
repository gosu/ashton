module Gosu
  class Image
    alias_method :draw_without_hash, :draw

    def draw(*args)
      if args.last.is_a? Hash
        shader = args.last[:shader]
        if shader
          $window.flush
          shader.use do
            shader.image = self
            shader.color = args[5].is_a?(Color) ? args[5] : [1, 1, 1, 1]
            draw_without_hash *args[0..-2]
          end
        else
          draw_without_hash *args[0..-2]
        end
      else
        draw_without_hash *args
      end
    end

    alias_method :draw_rot_without_hash, :draw_rot
    def draw_rot(*args)
      if args.last.is_a? Hash
        shader = args.last[:shader]
        if shader
          $window.flush
          shader.use do
            shader.image = self
            shader.color = args[8].is_a?(Color) ? args[8] : [1, 1, 1, 1]
            draw_rot_without_hash *args[0..-2]
          end
        else
          draw_rot_without_hash *args[0..-2]
        end
      else
        draw_rot_without_hash *args
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
      color = options[:color] || Gosu::Color::WHITE
      scale = options[:scale] || 10.0
      shader = options[:shader]
      mode = options[:mode] || :default

      opengl_color = color.is_a?(Gosu::Color) ? color.to_opengl : color

      if shader
        $window.flush # Ensure that other pending draws don't get shaded.
        shader.use do
          shader.image = self
          shader.color = color

          points.each do |x, y|
            draw_rot_without_hash x, y, z, 0, 0.5, 0.5, scale, scale, color, mode
          end
        end
      else
        points.each do |x, y|
          draw_rot_without_hash x, y, z, 0, 0.5, 0.5, scale, scale, color, mode
        end
      end
    end
  end
end