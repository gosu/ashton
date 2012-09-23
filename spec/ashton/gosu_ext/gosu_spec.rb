require_relative "../../helper.rb"

describe Gosu do
  describe "enable_undocumented_retrofication" do
    it "should set Texture.pixelated? true" do
      Ashton::Texture.should_not be_pixelated
      Gosu.enable_undocumented_retrofication
      Ashton::Texture.should be_pixelated
    end
  end
end