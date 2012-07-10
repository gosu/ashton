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
            draw_without_hash *args[0...-1]
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
            draw_rot_without_hash *args[0...-1]
          end
        else
          draw_rot_without_hash *args[0..-2]
        end
      else
        draw_rot_without_hash *args
      end
    end
  end
end