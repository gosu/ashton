module Ashton
  # Based on Catalin Zima's shader based dynamic shadows system.
  # http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/
  class LightManager
    include Enumerable

    def each(&block); @lights.each &block end
    def size; @lights.size end

    def initialize
      @lights = Set.new
      @shadows = Ashton::WindowBuffer.new
    end

    # @param light [Ashton::LightSource]
    # @return [Ashton::LightSource]
    def add(light)
      raise TypeError unless light.is_a? LightSource

      @lights << light
      light
    end
    alias_method :<<, :add

    def remove(light)
      @lights -= [light]
      light
    end

    # @see Ashton::LightSource#new
    #
    # @return [Ashton::LightSource]
    def create_light(*args)
      add LightSource.new(*args)
    end

    def draw(options = {})
      options = {
          blend: :multiply,
      }.merge! options

      @shadows.draw 0, 0, 0, options
    end

    def update_shadow_casters(&block)
      raise ArgumentError, "Requires block" unless block_given?

      # TODO: Need to only render to lights that are on-screen.
      @lights.each do |light|
        light.send :render_shadow_casters, &block
      end

      # Use each shader on every light, to save setting and un-setting shaders (a bit faster, depending on number of light sources).
      LightSource.distort_shader.use do
        @lights.each {|light| light.send :distort }
      end

      LightSource.draw_shadows_shader.use do
        @lights.each {|light| light.send :draw_shadows }
      end

      LightSource.blur_shader.use do
        @lights.each {|light| light.send :blur }
      end

      @shadows.render do |buffer|
        buffer.clear
        @lights.each {|light| light.draw }
      end

      nil
    end
  end
end