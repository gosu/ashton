require 'opengl'
require 'gosu' # Hope we are using 0.8 and all is lovely!

module Ashton
  module CreateWindowGlobal
    def initialize(*args, &block)
      $window = self
      super *args, &block
    end
  end
end

module Gosu
  class Window
    include Ashton::CreateWindowGlobal
  end
end

require "ashton/version"
require "ashton/shader"
require "ashton/framebuffer"
require "ashton/image_stub"