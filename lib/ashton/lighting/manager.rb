require 'set'

module Ashton
module Lighting
  # Based on Catalin Zima's shader based dynamic shadows system.
  # http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/
  class Manager
    include Enumerable

    attr_accessor :camera_x, :camera_y, :z

    def each(&block); @lights.each(&block) end
    def size; @lights.size end
    def empty?; @lights.empty? end
    def width; @shadows.width end
    def height; @shadows.height end

    def initialize(options = {})
      options = {
          width: $window.width,
          height: $window.height,
          camera_x: 0,
          camera_y: 0,
          z: 0,
      }.merge! options

      @camera_x, @camera_y = options[:camera_x], options[:camera_y]
      @z = options[:z]

      @lights = Set.new
      @shadows = Ashton::Texture.new options[:width], options[:height]
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
          mode: :multiply,
      }.merge! options

      @shadows.draw @camera_x, @camera_y, @z, options
    end

    def update_shadow_casters(&block)
      raise ArgumentError, "Requires block" unless block_given?

      unless empty?
        # TODO: Need to only render to lights that are on-screen.
        @lights.each do |light|
          light.send :render_shadow_casters, &block
        end

        # Use each shader on every light, to save setting and un-setting shaders (a bit faster, depending on number of light sources).
        LightSource.distort_shader.enable do
          @lights.each {|light| light.send :distort }
        end

        LightSource.draw_shadows_shader.enable do
          @lights.each {|light| light.send :draw_shadows }
        end

        LightSource.blur_shader.enable do
          @lights.each {|light| light.send :blur }
        end
      end

      @shadows.render do |buffer|
        buffer.clear
        $window.translate(-@camera_x, -@camera_y) do
          @lights.each {|light| light.draw } unless empty?
        end
      end

      nil
    end
  end
end
end