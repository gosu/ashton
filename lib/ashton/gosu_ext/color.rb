module Gosu
  class Color
    def self.from_opengl(array)
      rgba *array.map {|c| (c * 255).to_i }
    end

    # Convert to length 4 array of floats in range 0.0 to 1.0
    def to_opengl
      [red / 255.0, green / 255.0, blue / 255.0, alpha / 255.0]
    end
  end
end