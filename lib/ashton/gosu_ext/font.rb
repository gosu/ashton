module Gosu
  class Font
    DEFAULT_DRAW_COLOR = Gosu::Color::WHITE

    alias_method :draw_without_hash, :draw
    protected :draw_without_hash
    def draw(*args)
      args, shader = if args.last.is_a?(Hash)
                       [args[0..-2], args.last[:shader]]
                     else
                       [args, nil]
                     end

      z = args[3]

      if shader
        shader.enable z
        $window.gl z do
          Gl.glActiveTexture Gl::GL_TEXTURE0 # Let's make an assumption :)
          shader.color = args[6].is_a?(Color) ? args[6] : DEFAULT_DRAW_COLOR
        end
      end

      begin
        draw_without_hash(*args)
      ensure
        shader.disable z if shader
      end
    end

    alias_method :draw_rel_without_hash, :draw_rel
    protected :draw_rel_without_hash
    def draw_rel(*args)
      args, shader = if args.last.is_a?(Hash)
                       [args[0..-2], args.last[:shader]]
                     else
                       [args, nil]
                     end

      z = args[3]

      if shader
        shader.enable z
        $window.gl z do
          Gl.glActiveTexture GL::GL_TEXTURE0 # Let's make an assumption :)
          shader.color = args[8].is_a?(Color) ? args[8] : DEFAULT_DRAW_COLOR
        end
      end

      begin
        draw_rel_without_hash(*args)
      ensure
        shader.disable z if shader
      end
    end

  end
end