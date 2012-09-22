
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton::ImageStub do
  describe "#initialize" do
    it "should fail if the blob data is not the expected size" do
      lambda do
        described_class.new "\0\0\0", 2, 3
      end.should raise_error ArgumentError, /Expected blob to be 24 bytes/
    end

    it "should fail width <= 0" do
      lambda do
        described_class.new "\0\0\0\0", 0, 2
      end.should raise_error ArgumentError, /Width must be >= 1 pixel/
    end

    it "should fail height <= 0" do
      lambda do
        described_class.new "\0\0\0\0", 2, 0
      end.should raise_error ArgumentError, /Height must be >= 1 pixel/
    end
  end

  context "instantiated" do
    let(:two_by_three_blob) { 24.times.to_a.pack("C*") }
    let(:subject) { described_class.new two_by_three_blob, 2, 3 }

    describe "#to_blob" do
      it "should return the blob given" do
        subject.to_blob.should eq two_by_three_blob
      end
    end

    describe "#columns" do
      it "should equal the width of the blob" do
        subject.columns.should eq 2
      end
    end

    describe "#rows" do
      it "should equal the height of the blob" do
        subject.rows.should eq 3
      end
    end
  end
end