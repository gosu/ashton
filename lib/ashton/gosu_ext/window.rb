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