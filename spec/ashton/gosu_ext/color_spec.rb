require_relative "../../helper.rb"

describe Gosu::Color do
  let :conversions do
    [
        [Gosu::Color::RED,                  [1.0, 0.0, 0.0, 1.0]],
        [Gosu::Color::GREEN,                [0.0, 1.0, 0.0, 1.0]],
        [Gosu::Color::BLUE,                 [0.0, 0.0, 1.0, 1.0]],
        [Gosu::Color.rgba(25, 50, 75, 125), [0.09803921568627451, 0.19607843137254902, 0.29411764705882354, 0.49019607843137253]],
    ]
  end

  describe "to_opengl" do
    it "should convert from Color to float array" do
      conversions.each do |gosu, opengl|
        gosu.to_opengl.should eq opengl
      end
    end
  end

  describe ".from_opengl" do
    it "should create the expected Colors from a float array" do
      conversions.each do |gosu, opengl|
        Gosu::Color.from_opengl(opengl).should eq gosu
      end
    end
  end

  describe "to_i" do
    it "should convert to an ARGB8 value" do
      Gosu::Color.new(0x01234567).to_i.should eq 0x01234567
    end
  end
end