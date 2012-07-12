require File.expand_path("../../../helper.rb", __FILE__)

describe Gosu::Image do
  before :all do
    $window ||= Gosu::Window.new 16, 16, false
    @subject = described_class.new $window, media_path("LargeStar.png")
  end

  describe "draw" do
    it "should pass parameters through normally, without a hash" do
      mock(@subject).draw_without_hash 0, 1, 2, 3, 4, 5

      @subject.draw 0, 1, 2, 3, 4, 5
    end

    it "should pass parameters through normally, without :shader in the hash" do
      mock(@subject).draw_without_hash 0, 1, 2, 3, 4, 5

      @subject.draw 0, 1, 2, 3, 4, 5, {}
    end

    it "should use the shader if supplied" do
      mock(shader = Ashton::Shader.new) do |m|
        m.enable 2
        m.image = @subject
        m.disable 2
      end
      mock(@subject).draw_without_hash 0, 1, 2, 3, 4, 5

      @subject.draw 0, 1, 2, 3, 4, 5, :shader => shader
    end
  end

  describe "draw_rot" do
    it "should pass parameters through normally, without a hash" do
      mock(@subject).draw_rot_without_hash 0, 1, 2, 3, 4, 5, 6, 7, 8

      @subject.draw_rot 0, 1, 2, 3, 4, 5, 6, 7, 8
    end

    it "should pass parameters through normally, without :shader in the hash" do
      mock(@subject).draw_rot_without_hash 0, 1, 2, 3, 4, 5, 6, 7, 8

      @subject.draw_rot 0, 1, 2, 3, 4, 5, 6, 7, 8, {}
    end

    it "should use the shader if supplied" do
      mock(shader = Ashton::Shader.new) do |m|
        m.enable 2
        m.image = @subject
        m.disable 2
      end
      mock(@subject).draw_rot_without_hash 0, 1, 2, 3, 4, 5, 6, 7, 8

      @subject.draw_rot 0, 1, 2, 3, 4, 5, 6, 7, 8, :shader => shader
    end
  end
end