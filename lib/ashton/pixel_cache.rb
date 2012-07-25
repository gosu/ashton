module Ashton
  class PixelCache
    # Docs here.

    public
    # Convert the current contents of the cache into a Gosu::Image
    #
    # @option options :caching [Boolean] (true) TexPlay behaviour.
    # @option options :tileable [Boolean] (false) Standard Gosu behaviour.
    def to_image(options = {})
      options = {
          tileable: false,
      }.merge! options

      # Create a new Image from the flipped pixel data.
      stub = ImageStub.new to_blob, width, height
      if defined? TexPlay
        Gosu::Image.new $window, stub, options[:tileable], options
      else
        Gosu::Image.new $window, stub, options[:tileable]
      end
    end
  end
end