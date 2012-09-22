module Ashton
  # Used internally to create images from raw binary (blob) data.
  #
  # This object duck-types an RMagick image (#rows, #columns, #to_blob), so that Gosu will import it.
  class ImageStub

    # @return [Integer]
    attr_reader :rows
    # @return [Integer]
    attr_reader :columns

    # The first pixel in the blob will be at the top left hand corner of the created image, since that is the orientation
    # of Gosu images.
    #
    # @param [String] blob_data Raw data string to import. Must be RGBA ordered, (4 * width * height) bytes in length.
    # @param [Integer] width Number of pixels wide.
    # @param [Integer] height Number of pixels high.
    def initialize(blob_data, width, height)
      raise ArgumentError, "Width must be >= 1 pixel" unless width > 0
      raise ArgumentError, "Height must be >= 1 pixel" unless height > 0

      expected_size = width * height * 4
      raise ArgumentError, "Expected blob to be #{expected_size} bytes" unless blob_data.size == expected_size

      @data, @columns, @rows = blob_data, width, height
    end

    # @return [String]
    def to_blob
      @data
    end
  end
end