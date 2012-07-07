module Ashton
  # Used internally to create images from raw binary (blob) data.
  #
  # This object duck-types an RMagick image (#rows, #columns, #to_blob), so that Gosu will import it.
  class ImageStub

    # @return [Integer]
    attr_reader :rows, :columns

    # The first pixel in the blob will be at the top left hand corner of the created image, since that is the orientation
    # of Gosu images.
    #
    # @param [String] blob_data Raw data string to import. Must be RGBA ordered, (4 * width * height) bytes in length.
    # @param [Integer] width Number of pixels wide.
    # @param [Integer] height Number of pixels high.
    def initialize(blob_data, width, height)
      @data, @columns, @rows = blob_data, width, height
    end

    # @return [String]
    def to_blob
      @data
    end
  end

  # Used internally to create blank images (red/blue/green/alpha all 0).
  #
  # Credit to philomory for this class.
  class EmptyImageStub < ImageStub
    # @param width (see ImageStub#initialize)
    # @param height (see ImageStub#initialize)
    def initialize(width, height)
      #raise ArgumentError if (width > TexPlay::TP_MAX_QUAD_SIZE || height > TexPlay::TP_MAX_QUAD_SIZE)
      super('\0' * (width * height * 4), width, height)
    end
  end
end