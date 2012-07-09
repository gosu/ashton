require 'opengl'
require 'gosu'



module Ashton
  class Error < RuntimeError; end

  class NotSupportedError < Error; end

  class ShaderError < Error; end
  class ShaderCompileError < ShaderError; end
  class ShaderLinkError < ShaderError; end
  class ShaderUniformError < ShaderError; end
  class ShaderAttributeError < ShaderError; end
end

require "ashton/gosu_ext/window"
require "ashton/gosu_ext/image"
require "ashton/gosu_ext/color"

require "ashton/version"
require "ashton/shader"
require "ashton/post_process"
require "ashton/framebuffer"
require "ashton/image_stub"