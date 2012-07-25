
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton::PixelCache do
  before :all do
    $window ||= Gosu::Window.new 16, 16, false
    @testcard_image = Gosu::Image.new $window, media_path("simple.png")
  end

  before :each do
    @framebuffer = Ashton::Framebuffer.new @testcard_image.width, @testcard_image.height
    @framebuffer.render do
      @testcard_image.draw 0, 0, 0
    end

    @subject = described_class.new @framebuffer
  end

  describe "owner" do
    it "should remember the owner it was created for" do
      @subject.owner.should eq @framebuffer
    end
  end

  describe "refresh" do
    it "should respond to refresh" do
      @subject.should respond_to :refresh
    end
  end

  describe "initialize" do
    it "should cache for a framebuffer class" do
      ->{ described_class.new @framebuffer }.should_not raise_error TypeError
    end

    it "should cache for an image class" do
      pending "it not freezing :/"
      ->{ described_class.new @testcard_image }.should_not raise_error TypeError
    end

    it "should fail passed an unexpected class" do
      ->{ described_class.new "frog" }.should raise_error TypeError
    end
  end

  describe "[]" do
    it "should return the color of the pixel" do
      @subject[0, 0].should eq Gosu::Color::WHITE
      @subject[0, 1].should eq Gosu::Color::RED
      @subject[0, 2].should eq Gosu::Color::GREEN
      @subject[0, 3].should eq Gosu::Color::BLUE
      @subject[0, 8].should eq Gosu::Color.rgba(0, 0, 0, 0)
    end

    it "should return a null colour outside the texture" do
      @subject[0, -1].should eq Gosu::Color.new 0
      @subject[-1, 0].should eq Gosu::Color.new 0
      @subject[16, 0].should eq Gosu::Color.new 0
      @subject[0, 12].should eq Gosu::Color.new 0
    end
  end

  describe "rgba" do
    it "should return the appropriate array of values" do
      @subject.rgba(0, 0).should eq [255, 255, 255, 255]
      @subject.rgba(0, 1).should eq [255, 0, 0, 255]
      @subject.rgba(0, 2).should eq [0, 255, 0, 255]
      @subject.rgba(0, 3).should eq [0, 0, 255, 255]
      @subject.rgba(0, 8).should eq [0, 0, 0, 0]
    end
  end

  describe "red" do
    it "should return the appropriate value" do
      @subject.red(0, 0).should eq 255
      @subject.red(0, 1).should eq 255
      @subject.red(0, 2).should eq 0
      @subject.red(0, 3).should eq 0
      @subject.red(0, 8).should eq 0
    end
  end

  describe "green" do
    it "should return the appropriate value" do
      @subject.green(0, 0).should eq 255
      @subject.green(0, 1).should eq 0
      @subject.green(0, 2).should eq 255
      @subject.green(0, 3).should eq 0
      @subject.green(0, 8).should eq 0
    end
  end

  describe "blue" do
    it "should return the appropriate value" do
      @subject.blue(0, 0).should eq 255
      @subject.blue(0, 1).should eq 0
      @subject.blue(0, 2).should eq 0
      @subject.blue(0, 3).should eq 255
      @subject.blue(0, 8).should eq 0
    end
  end

  describe "alpha" do
    it "should return the appropriate value" do
      @subject.alpha(0, 0).should eq 255
      @subject.alpha(0, 1).should eq 255
      @subject.alpha(0, 2).should eq 255
      @subject.alpha(0, 3).should eq 255
      @subject.alpha(0, 8).should eq 0
    end
  end

  describe "transparent?" do
    it "should be false where the buffer is opaque or semi-transparent" do
      @subject.transparent?(0, 1).should eq false
      @subject.transparent?(0, 5).should eq false
    end

    it "should be true where the buffer is transparent" do
      @subject.transparent?(0, 8).should eq true
    end
  end

  describe "width" do
    it "should be initially set" do
      @subject.width.should eq @testcard_image.width
    end
  end

  describe "height" do
    it "should be initially set" do
      @subject.height.should eq @testcard_image.height
    end
  end

  describe "to_blob" do
    it "should create a blob identical to one an equivalent image would create" do
      @subject.to_blob.should eq @testcard_image.to_blob
    end
  end

  describe "to_image" do
    before :each do
      @image = @subject.to_image
    end

    it "should create a Gosu::Image" do
      @image.should be_kind_of Gosu::Image
    end

    it "should create an image of the appropriate size" do
      @image.width.should eq @testcard_image.width
      @image.height.should eq @testcard_image.height
    end

    it "should create an image identical to the one that was drawn into it originally" do
      @image.to_blob.should eq @testcard_image.to_blob
    end
  end
end