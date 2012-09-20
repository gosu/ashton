require File.expand_path("../../../helper.rb", __FILE__)

describe Gosu::Font do
  before :each do
    $window = Gosu::Window.new 16, 16, false
  end
  let(:subject) { described_class.new $window, Gosu::default_font_name, 20 }
  let(:shader) { Ashton::Shader.new }

  describe "draw" do
    it "should pass parameters through normally, without a hash" do
      mock(subject).draw_without_hash "bleh", 1, 2, 3, 4, 5, 6, 7

      subject.draw "bleh", 1, 2, 3, 4, 5, 6, 7
    end

    it "should pass parameters through normally, without :shader in the hash" do
      mock(subject).draw_without_hash "bleh", 1, 2, 3, 4, 5, 6, 7

      subject.draw "bleh", 1, 2, 3, 4, 5, 6, 7, shader: shader
    end

    it "should use the shader if supplied" do
      mock(shader) do |m|
        m.enable 3
        m.disable 3
      end
      mock(subject).draw_without_hash "bleh", 1, 2, 3, 4, 5, 6, 7

      subject.draw "bleh", 1, 2, 3, 4, 5, 6, 7, shader: shader
    end
  end

  describe "draw_rel" do
    it "should pass parameters through normally, without a hash" do
      mock(subject).draw_rel_without_hash "bleh", 1, 2, 3, 4, 5, 6, 7, 8, 9

      subject.draw_rel "bleh", 1, 2, 3, 4, 5, 6, 7, 8, 9
    end

    it "should pass parameters through normally, without :shader in the hash" do
      mock(subject).draw_rel_without_hash "bleh", 1, 2, 3, 4, 5, 6, 7, 8, 9

      subject.draw_rel "bleh", 1, 2, 3, 4, 5, 6, 7, 8, 9, shader: shader
    end

    it "should use the shader if supplied" do
      mock(shader) do |m|
        m.enable 3
        m.disable 3
      end
      mock(subject).draw_rel_without_hash "bleh", 1, 2, 3, 4, 5, 6, 7, 8, 9

      subject.draw_rel "bleh", 1, 2, 3, 4, 5, 6, 7, 8, 9, shader: shader
    end
  end
end