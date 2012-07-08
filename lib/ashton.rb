require 'opengl'
require 'gosu'

# Set the window global, in case it hasn't been set (e.g. by Chingu)
module Gosu
  class Window
    alias_method :ashton_initialize, :initialize
    def initialize(*args, &block)
      $window = self
      ashton_initialize *args, &block
    end
  end
end

module Ashton
  class Error < RuntimeError; end

  class ShaderError < Error; end
  class ShaderCompileError < ShaderError; end
  class ShaderLinkError < ShaderError; end
  class ShaderUniformError < ShaderError; end
  class ShaderAttributeError < ShaderError; end
end

require "ashton/version"
require "ashton/shader"
require "ashton/post_process"
require "ashton/framebuffer"
require "ashton/image_stub"