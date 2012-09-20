
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton::Texture do
  before :each do
    $window = Gosu::Window.new 16, 16, false # Horrible, but otherwise we can't flush out "wrong" params properly.
  end

  let(:testcard_image) { Gosu::Image.new $window, media_path("simple.png") }
  let(:subject) { described_class.new testcard_image }

  describe "initialize" do
    it "should fail with too few arguments" do
      ->{ described_class.new }.should raise_error ArgumentError, /Expected 1, 2 or 3 parameters./
    end

    it "should fail with too many arguments" do
      ->{ described_class.new 1, 2, 3, 4 }.should raise_error ArgumentError, /Expected 1, 2 or 3 parameters./
    end

    it "should fail if the texture size is too large" do
      ->{ described_class.new 100000, 100000 }.should raise_error ArgumentError, /Unable to create a texture of size 100000x100000/
    end

    describe "creating blank image (1 parameter)" do
      let(:subject) { described_class.new 10, 12 }

      it "should be of the expected size" do
        subject.width.should eq 10
        subject.height.should eq 12
      end

      it "should be totally blank" do
        color = Gosu::Color.rgba 0, 0, 0, 0
        10.times do |x|
          12.times do |y|
            subject[x, y].should eq color
          end
        end
      end
    end

    describe "creating from Gosu::Image (2 parameters)" do
      let(:image) { testcard_image }
      let(:subject) { described_class.new image }

      it "should be of the expected size" do
        subject.width.should eq image.width
        subject.height.should eq image.height
      end

      it "should be an identical copy of the image" do
        subject.to_blob.should eq image.to_blob
      end
    end

    describe "creating from blob (3 parameters)" do
      let(:image) { testcard_image }
      let(:subject) { described_class.new image.to_blob, image.width, image.height }

      it "should fail if the width/height are not the expected size" do
        ->{ described_class.new image.to_blob, image.width, image.height + 1 }.should raise_error ArgumentError, /Blob data is not of expected size/
      end

      it "should be of the expected size" do
        subject.width.should eq image.width
        subject.height.should eq image.height
      end

      it "should be filled with the blob data" do
        subject.to_blob.should eq image.to_blob
      end
    end
  end

  describe "id" do
    it "should be a positive number" do
      subject.id.should be_kind_of Integer
      subject.id.should > 0
    end
  end

  describe "fbo_id" do
    it "should be a positive number" do
      subject.fbo_id.should be_kind_of Integer
      subject.fbo_id.should > 0
    end
  end

  describe "cache" do
    it "should be a PixelCache" do
      subject.cache.should be_kind_of Ashton::PixelCache
    end

    it "should be of the right size" do
      subject.cache.width.should eq testcard_image.width
      subject.cache.height.should eq testcard_image.height
    end

    it "should consider the Texture its owner" do
      subject.cache.owner.should eq subject
    end
  end

  describe "refresh_cache" do
    it "should be defined" do
      subject.should respond_to :refresh_cache
    end
  end

  describe "[]" do
    it "should return the color of the pixel" do
      subject[0, 0].should eq Gosu::Color::WHITE
      subject[0, 1].should eq Gosu::Color::RED
      subject[0, 2].should eq Gosu::Color::GREEN
      subject[0, 3].should eq Gosu::Color::BLUE
      subject[0, 4].should eq Gosu::Color.rgba(255, 255, 255, 153)
      subject[0, 8].should eq Gosu::Color.rgba(0, 0, 0, 0)
    end

    it "should return a null colour outside the texture" do
      subject[0, -1].should eq Gosu::Color.new 0
      subject[-1, 0].should eq Gosu::Color.new 0
      subject[16, 0].should eq Gosu::Color.new 0
      subject[0, 12].should eq Gosu::Color.new 0
    end
  end

  describe "rgba" do
    it "should return the appropriate array of values" do
      subject.rgba(0, 0).should eq [255, 255, 255, 255]
      subject.rgba(0, 1).should eq [255, 0, 0, 255]
      subject.rgba(0, 2).should eq [0, 255, 0, 255]
      subject.rgba(0, 3).should eq [0, 0, 255, 255]
      subject.rgba(0, 4).should eq [255, 255, 255, 153]
      subject.rgba(0, 8).should eq [0, 0, 0, 0]
    end
  end

  describe "red" do
    it "should return the appropriate value" do
      subject.red(0, 0).should eq 255
      subject.red(0, 1).should eq 255
      subject.red(0, 2).should eq 0
      subject.red(0, 3).should eq 0
      subject.red(0, 8).should eq 0
    end
  end

  describe "green" do
    it "should return the appropriate value" do
      subject.green(0, 0).should eq 255
      subject.green(0, 1).should eq 0
      subject.green(0, 2).should eq 255
      subject.green(0, 3).should eq 0
      subject.green(0, 8).should eq 0
    end
  end

  describe "blue" do
    it "should return the appropriate value" do
      subject.blue(0, 0).should eq 255
      subject.blue(0, 1).should eq 0
      subject.blue(0, 2).should eq 0
      subject.blue(0, 3).should eq 255
      subject.blue(0, 8).should eq 0
    end
  end

  describe "alpha" do
    it "should return the appropriate value" do
      subject.alpha(0, 0).should eq 255
      subject.alpha(0, 1).should eq 255
      subject.alpha(0, 2).should eq 255
      subject.alpha(0, 3).should eq 255
      subject.alpha(0, 8).should eq 0
    end
  end

  describe "transparent?" do
    it "should be false where the buffer is opaque or semi-transparent" do
      subject.transparent?(0, 1).should be_false
      subject.transparent?(0, 5).should be_false
    end

    it "should be true where the buffer is transparent" do
      subject.transparent?(0, 8).should be_true
    end
  end

  describe "width" do
    it "should be initially set" do
      subject.width.should eq testcard_image.width
    end
  end

  describe "height" do
    it "should be initially set" do
      subject.height.should eq testcard_image.height
    end
  end

  describe "render" do
    it "should fail without a block" do
      ->{ subject.render }.should raise_error ArgumentError
    end

    it "should passing itself into the block" do
      buffer = nil
      subject.render do |fb|
        buffer = fb
      end

      buffer.should eq subject
    end

    it "should bind the rendering during the block" do
      pending
    end

    it "should reset to rendering to the window after the block" do
      pending
    end

    it "should fail without a block" do
      lambda { subject.render }.should raise_error ArgumentError
    end
  end

  describe "clear" do
    it "should clear the buffer to transparent" do
      subject.clear
      subject.width.times do |x|
        subject.height.times do |y|
          subject[x, y].should eq Gosu::Color.rgba(0, 0, 0, 0)
        end
      end
    end

    it "should clear the buffer to a specified Gosu::Color" do
      subject.clear color: Gosu::Color::CYAN
      subject.width.times do |x|
        subject.height.times do |y|
          subject[x, y].should eq Gosu::Color::CYAN
        end
      end
    end

    it "should clear the buffer to a specified opengl color float array" do
      subject.clear color: Gosu::Color::CYAN.to_opengl
      subject.width.times do |x|
        subject.height.times do |y|
          subject[x, y].should eq Gosu::Color::CYAN
        end
      end
    end
  end

  describe "draw" do
    it "should be able to be drawn" do
      subject.draw 1, 2, 3
    end

    it "should be drawn with a specific blend mode" do
      [:alpha_blend, :add, :multiply, :replace].each do |mode|
        subject.draw 1, 2, 3, mode: mode
      end
    end

    it "should fail with a bad blend mode name" do
      ->{ subject.draw 1, 2, 3, mode: :fish }.should raise_error(ArgumentError, /Unsupported draw :mode, :fish/)
    end

    it "should fail with a bad blend mode type" do
      ->{ subject.draw 1, 2, 3, mode: 12 }.should raise_error TypeError
    end

    it "should be drawn with a specific color" do
      subject.draw 1, 2, 3, color: Gosu::Color::RED
    end

    it "should fail with a bad color type" do
      ->{ subject.draw 1, 2, 3, color: 12 }.should raise_error TypeError
    end

    it "should be drawn with a specific shader" do
      subject.draw 1, 2, 3, shader: Ashton::Shader.new
    end

    it "should fail with a bad shader type" do
      ->{ subject.draw 1, 2, 3, shader: 12 }.should raise_error TypeError
    end

    it "should draw with a Texture passed to multitexture" do
      subject.draw 1, 2, 3, multitexture: Ashton::Texture.new(10, 10)
    end

    it "should fail with a bad multitexture option" do
      ->{ subject.draw 1, 2, 3, multitexture: :fish }.should raise_error(TypeError, /Expected :multitexture option of type Ashton::Texture/)
    end
  end

  describe "to_blob" do
    it "should create a blob the same as an equivalent image would" do
      subject.to_blob.should eq testcard_image.to_blob
    end
  end

  describe "to_image" do
    let(:image) { subject.to_image }

    it "should create a Gosu::Image" do
      image.should be_kind_of Gosu::Image
    end

    it "should create an image of the appropriate size" do
      image.width.should eq testcard_image.width
      image.height.should eq testcard_image.height
    end

    it "should create an image identical to the one that was drawn into it originally" do
      image.to_blob.should eq testcard_image.to_blob
    end
  end

  describe "dup" do
    it "should create a new Texture object" do
      new = subject.dup.should be_kind_of described_class
      new.should_not be subject
    end

    it "should create an exact copy of the Texture" do
      subject.dup.to_blob.should eq subject.to_blob
    end
  end
end