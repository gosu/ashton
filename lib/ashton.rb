require 'opengl'
require 'gosu'

begin
  RUBY_VERSION =~ /(\d+.\d+)/
  require "ashton/#{$1}/ashton.so"
rescue LoadError
  require "ashton/ashton.so"
end

module Ashton
  class Error < RuntimeError; end

  class NotSupportedError < Error; end

  class ShaderError < Error; end
  class ShaderCompileError < ShaderError; end
  class ShaderLinkError < ShaderError; end
  class ShaderUniformError < ShaderError; end
  class ShaderAttributeError < ShaderError; end
  class ShaderLoadError < ShaderError; end
end

require "ashton/gosu_ext/window"
require "ashton/gosu_ext/font"
require "ashton/gosu_ext/image"
require "ashton/gosu_ext/color"

require "ashton/mixins/utilities"

require "ashton/version"
require "ashton/shader"
require "ashton/framebuffer"
require "ashton/light_source"
require "ashton/light_manager"
require "ashton/window_buffer"
require "ashton/image_stub"
require "ashton/particle_emitter"