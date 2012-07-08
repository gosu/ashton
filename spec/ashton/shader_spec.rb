
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton::Shader do
  before :each do
    @subject = described_class.new # Default code.
  end

  describe "initialize" do
    it "should not be current?" do
      @subject.should_not be_current
    end
  end

  describe "use" do
    pending
  end

  describe "dup" do
    it "should create a new object containing the same source" do
      new_shader = @subject.dup
      new_shader.vertex_source.should eq @subject.vertex_source
      new_shader.fragment_source.should eq @subject.fragment_source
    end
  end

  describe "disable" do
    pending
  end

  describe "current?" do
    pending
  end

  describe "image=" do
    pending
  end

  describe "color=" do
    pending
  end

  describe "[]=" do
    pending
  end

  describe "[]" do
    pending "implementation"
  end

  describe "uniform" do
    pending
  end

  describe "attribute" do
    pending
  end

  describe "compile" do
    pending
  end

  describe "link" do
    pending
  end
end