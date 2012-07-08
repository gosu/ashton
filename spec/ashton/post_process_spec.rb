
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton::Shader do
  before :each do
    @subject = described_class.new # Default code.
  end

  describe "self.canvas_texture" do
    pending
  end

  describe "initialize" do
    it "should not be current?" do
      @subject.should_not be_current
    end
  end

  describe "process" do
    pending
  end
end