require_relative "../helper.rb"


describe Ashton::SignedDistanceField do
  before :all do
    Gosu::enable_undocumented_retrofication

    $window ||= Gosu::Window.new 16, 16, false
  end

  let(:max_distance) { 3 }
  let(:width) { 9 }
  let(:height) { 10 }

  let(:subject) do
    described_class.new width, height, max_distance do
      # ---------
      # -XXX-----
      # -XXXX----
      # -XXXX----
      # ---------
      # ---------
      # ---------
      # ---------
      # ---------
      # ---------
      $window.pixel.draw 1, 1, 0, 3, 3
      $window.pixel.draw 4, 2, 0, 1, 2
    end
  end

  describe "initialize" do
    it "should accept a block and yield itself" do
      yielded = nil
      field = described_class.new width, height, max_distance do |value|
        yielded = value
      end

      yielded.should eq field
    end

    it "should initialize itself to max_distance if not given a block" do
      field = described_class.new width, height, max_distance
      field.to_a.flatten.uniq.should eq [max_distance]
    end
  end

  describe "width" do
    it "should give the width" do
      subject.width.should eq width
    end
  end

  describe "height" do
    it "should give the height" do
      subject.height.should eq height
    end
  end

  describe "position_clear?" do
    it "should be true if there is room" do
      subject.position_clear?(8, 4, 2).should be_true
    end

    it "should be false if there is no room" do
      subject.position_clear?(8, 4, 4).should be_false
    end

    it "should be false inside a solid" do
      subject.position_clear?(2, 2, 1).should be_false
    end
  end

  describe "sample_distance" do
    it "should give the appropriate distance" do
      subject.sample_distance(1, 0).should eq 1
      subject.sample_distance(7, 4).should eq 3
      subject.sample_distance(1, 1).should eq 0
      subject.sample_distance(2, 2).should eq -1
    end

    it "should max out at the specified limit" do
      subject.sample_distance(8, 9).should eq max_distance
    end
  end

  describe "line_of_sight?" do
    it "should be false if the sight line is blocked" do
      subject.line_of_sight?(2, 0, 2, 9).should be_false
    end

    it "should be true if the sight line is uninterrupted" do
      subject.line_of_sight?(0, 0, 0, 9).should be_true
    end
  end

  describe "line_of_sight_blocked_at" do
    it "should be false if the sight line is blocked" do
      subject.line_of_sight_blocked_at(2, 0, 2, 9).should eq [2, 1]
    end

    it "should be nil if the sight line is uninterrupted" do
      subject.line_of_sight_blocked_at(0, 0, 0, 9).should be_nil
    end
  end

  describe "sample_gradient" do
    it "should give expected values" do
      subject.sample_gradient(1, 0).should eq [0, -1]
      subject.sample_gradient(0, 1).should eq [-1, 0]

      subject.sample_gradient(5, 3).should eq [2, 0]
      subject.sample_gradient(1, 4).should eq [0, 2]
    end
  end

  describe "sample_normal" do
    it "should give expected values" do
      subject.sample_normal(1, 0).should eq [0.0, -1.0]
      subject.sample_normal(0, 1).should eq [-1.0, 0.0]

      subject.sample_normal(5, 3).should eq [1.0, 0.0]
      subject.sample_normal(1, 4).should eq [0.0, 1.0]
    end
  end

  describe "render_field" do
    it "should yield the field" do
      field = nil
      subject.render_field do |value|
        field = value
      end
      field.should eq subject
    end

    it "should fail without a block" do
      ->{ subject.render_field }.should raise_error ArgumentError
    end

    pending
  end

  describe "draw" do
    pending
  end

  describe "to_a" do
    it "should generate the expected array" do
      # Remember this is rotated so array[x][y] works.
      subject.to_a.should eq [
          [1, 1,  1, 1, 1, 2, 3, 3, 3, 3],
          [1, 0,  0, 0, 1, 2, 3, 3, 3, 3],
          [1, 0, -1, 0, 1, 2, 3, 3, 3, 3],
          [1, 0,  0, 0, 1, 2, 3, 3, 3, 3],
          [1, 1,  0, 0, 1, 2, 3, 3, 3, 3],
          [2, 1,  1, 1, 1, 2, 3, 3, 3, 3],
          [3, 2,  2, 2, 2, 3, 3, 3, 3, 3],
          [3, 3,  3, 3, 3, 3, 3, 3, 3, 3],
          [3, 3,  3, 3, 3, 3, 3, 3, 3, 3],
      ]
    end
  end
end