require 'opengl'
require 'gosu'

begin
  RUBY_VERSION =~ /(\d+.\d+)/
  require_relative "ashton/#{$1}/ashton.#{RbConfig::CONFIG['DLEXT']}"
rescue LoadError
  require_relative "ashton/ashton.#{RbConfig::CONFIG['DLEXT']}"
end

module Ashton
  class Error < StandardError; end

  class NotSupportedError < Error; end

  class ShaderError < Error; end
  class ShaderCompileError < ShaderError; end
  class ShaderLinkError < ShaderError; end
  class ShaderUniformError < ShaderError; end
  class ShaderAttributeError < ShaderError; end
  class ShaderLoadError < ShaderError; end
end

require_relative "ashton/gosu_ext/gosu_module"

require_relative "ashton/mixins/version_checking"

require_relative "ashton/version"
require_relative "ashton/shader"
require_relative "ashton/signed_distance_field"
require_relative "ashton/texture"
require_relative "ashton/window_buffer"
require_relative "ashton/image_stub"
require_relative "ashton/particle_emitter"
require_relative "ashton/pixel_cache"

require_relative "ashton/lighting/light_source"
require_relative "ashton/lighting/manager"
