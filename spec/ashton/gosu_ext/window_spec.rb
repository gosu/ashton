require File.expand_path("../../../helper.rb", __FILE__)

describe Gosu::Window do
  before :all do
    $window ||= Gosu::Window.new 16, 16, false
  end

  describe "post_process" do
    pending
  end

  describe "Window.pixel" do
    it "should be a 1x1 image" do
      described_class.pixel.should be_kind_of Gosu::Image
      described_class.pixel.width.should eq 1
      described_class.pixel.height.should eq 1
    end

    it "should be white" do
      described_class.pixel[0, 0].should eq [1.0, 1.0, 1.0, 1.0]
    end
  end

  describe "Window.primary_buffer" do
    it "should be a window sized buffer" do
      described_class.primary_buffer.should be_kind_of Ashton::WindowBuffer
    end
  end

  describe "Window.secondary_buffer" do
    it "should be a window sized buffer" do
      described_class.secondary_buffer.should be_kind_of Ashton::WindowBuffer
    end
  end
end