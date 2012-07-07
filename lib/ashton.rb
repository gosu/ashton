require 'opengl'
require 'gosu' # Hope we are using 0.8 and all is lovely!

# Set the window global, in case it hasn't been set (e.g. by Chingu)
module Ashton
  module SetWindowGlobal
    def initialize(*args, &block)
      $window = self
      super *args, &block
    end
  end
end

module Gosu
  class Window
    include Ashton::SetWindowGlobal
  end
end

require "ashton/version"
require "ashton/shader"
require "ashton/framebuffer"
require "ashton/image_stub"