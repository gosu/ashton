require "ashton/base_shader"

module Ashton
  class Shader < BaseShader
    attr_reader :image

    shader_path = File.expand_path "../shader", __FILE__
    DEFAULT_VERTEX_SOURCE = File.read File.join(shader_path, "default.vert")
    DEFAULT_FRAGMENT_SOURCE = File.read File.join(shader_path, "default.frag")

    # Todo: Pass in a filename (String) or name of built-in pp shader (Symbol)
    #
    # @option options [String] :vertex Source code for vertex shader.
    # @option options [String] :vert equivalent to :vertex
    # @option options [String] :fragment Source code for fragment shader.
    # @option options [String] :frag equivalent to :fragment
    def initialize(options = {})
      @image = nil

      vertex_source = options[:vertex] || options[:vert] || DEFAULT_VERTEX_SOURCE
      fragment_source = options[:fragment] || options[:frag] || DEFAULT_FRAGMENT_SOURCE

      super vertex_source, fragment_source
      link

      @color = [1, 1, 1, 1]
    end

    def image=(image)
      use do
        if image
          info = image.gl_tex_info

          # Bind the single texture to 'in_Texture'
          glActiveTexture GL_TEXTURE0
          glBindTexture GL_TEXTURE_2D, info.tex_name
          self["in_Texture"] = 0
          raise unless glGetIntegerv(GL_ACTIVE_TEXTURE) == GL_TEXTURE0

          # Ensure that the shader knows to use the texture.
          self["in_TextureEnabled"] = true

          self["in_SpriteOffset"] = [info.left, info.top]
          self["in_SpriteSize"] = [info.right - info.left, info.bottom - info.top]
        else
          begin
            self["in_TextureEnabled"] = false
          rescue
          end
        end
      end

      @image = image
    end

    def color=(color)
      raise unless current?
      glVertexAttrib4f attribute("in_Color"), *color
      @color = color
    end
  end
end