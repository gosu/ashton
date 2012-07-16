
require File.expand_path("../../helper.rb", __FILE__)

# Values and their defaults. The deviations default to 0.
FLOATS_WITH_RANGE = {
    angular_velocity: 0.0..0.0,
    center_x: 0.5..0.5,
    center_y: 0.5..0.5,
    fade: 0.0..0.0,
    friction: 0.0..0.0,
    interval: Float::INFINITY..Float::INFINITY,
    scale: 1.0..1.0,
    speed: 0.0..0.0,
    time_to_live: Float::INFINITY..Float::INFINITY,
    zoom: 0.0..0.0,
}

describe Ashton::ParticleEmitter do
  before :all do
    $window ||= Gosu::Window.new 16, 16, false
  end

  before :each do
    @default_max = 1000
    @subject = described_class.new 1, 2, 3
  end

  describe "initialize" do
    [:x, :y, :z].each.with_index(1) do |attr, value|
      it "should set #{attr}" do
        @subject.send(attr).should be_kind_of Float
        @subject.send(attr).should eq value
      end
    end

    FLOATS_WITH_RANGE.each_pair do |attr, expected|
      it "should set #{attr}" do
        @subject.send(attr).should be_kind_of Range
        @subject.send(attr).should eq expected
      end
    end

    it "should be set max_particles" do
      @subject.max_particles.should be_kind_of Fixnum
      @subject.max_particles.should eq @default_max
    end

    it "should not have any particles" do
      @subject.count.should eq 0
    end

    it "should have color set to white" do
      @subject.color.should eq Gosu::Color::WHITE
    end
  end

  [:x, :y, :z].each.with_index(1) do |attr, value|
    describe "#{attr}=" do
      it "should set the value of #{attr}" do
        ->{ @subject.send "#{attr}=", value + 5.0 }.should change(@subject, attr).from(value).to(value + 5)
      end
    end
  end

  FLOATS_WITH_RANGE.keys.each do |attr|
    describe "#{attr}=" do
      it "should set #{attr} with a number" do
        @subject.send("#{attr}=", 42.0).should eq 42.0
        @subject.send("#{attr}").should eq 42.0..42.0
      end

      it "should set #{attr} with a range" do
        @subject.send("#{attr}=", 42.0..99.0).should eq 42.0..99.0
        @subject.send("#{attr}").should eq 42.0..99.0
      end
    end
  end

  describe "color=" do
    it "should set color" do
      (@subject.color = Gosu::Color::BLACK).should eq Gosu::Color::BLACK
      @subject.color.should eq Gosu::Color::BLACK
    end
  end

  describe "draw" do
    it "should not draw anything if there aren't any particles'" do
      dont_allow(@subject.instance_variable_get(:@image)).draw_as_points
      @subject.draw
    end

    it "should draw all active particles" do
      pending "way to tell if C functions are called!"
      @subject.draw
    end
  end

  describe "emit" do
    it "should create one more particle" do
      ->{ @subject.emit }.should change(@subject, :count).from(0).to(1)
    end

    it "should replace a particle if we are already at max particles" do
      (@default_max + 1).times { @subject.emit }
      @subject.count.should eq @default_max
    end
  end

  describe "update" do
    it "should emit a particle" do
      mock(@subject).emit
      @subject.update
    end
  end
end