require_relative "window"
require_relative "font"
require_relative "image"
require_relative "color"

module Gosu
  class << self
    alias_method :original_enable_undocumented_retrofication, :enable_undocumented_retrofication
    protected :original_enable_undocumented_retrofication

    def enable_undocumented_retrofication
      Ashton::Texture.pixelated = true
      original_enable_undocumented_retrofication
    end
  end
end