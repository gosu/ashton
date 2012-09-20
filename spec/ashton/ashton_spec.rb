
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton do
  let(:accuracy) { 0.000001 }

  describe "fast_sin" do
    it "should give the same result as Math.sin" do
      (-360..360).step 90 do |angle|
        Ashton.fast_sin(angle).should be_within(accuracy).of Math.sin(angle.gosu_to_radians)
      end
    end
  end

  describe "fast_cos" do
    it "should give the same result as Math.cos" do
      (-360..360).step 90 do |angle|
        Ashton.fast_cos(angle).should be_within(accuracy).of Math.cos(angle.gosu_to_radians)
      end
    end
  end
end
