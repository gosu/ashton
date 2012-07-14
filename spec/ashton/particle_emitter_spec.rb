
require File.expand_path("../../helper.rb", __FILE__)

# Values and their defaults. The deviations default to 0.
FLOATS_WITH_DEVIATIONS = {
    angular_velocity: 0.0,
    fade: 0.0,
    friction: 0.0,
    interval: Float::INFINITY,
    scale: 1.0,
    speed: 0.0,
    time_to_live: Float::INFINITY,
    zoom: 0.0,
}

describe Ashton::ParticleEmitter do
  before :all do
    $window ||= Gosu::Window.new 16, 16, false
  end

  before :each do
    @default_max = 100
    @subject = described_class.new 1, 2, 3
  end

  describe "initialize" do
    [:x, :y, :z].each.with_index(1) do |attr, value|
      it "should set #{attr}" do
        @subject.send(attr).should be_kind_of Float
        @subject.send(attr).should eq value
      end
    end

    FLOATS_WITH_DEVIATIONS.each_pair do |attr, expected|
      it "should set #{attr}" do
        @subject.send(attr).should be_kind_of Float
        @subject.send(attr).should eq expected
      end

      it "should set #{attr}_deviation" do
        @subject.send("#{attr}_deviation").should be_kind_of Float
        @subject.send("#{attr}_deviation").should eq 0.0
      end
    end

    it "should be set max_particles" do
      @subject.max_particles.should be_kind_of Fixnum
      @subject.max_particles.should eq @default_max
    end

    it "should not have any particles" do
      @subject.count.should eq 0
    end
  end

  [:x, :y, :z].each.with_index(1) do |attr, value|
    describe "#{attr}=" do
      it "should set the value of #{attr}" do
        ->{ @subject.send "#{attr}=", value + 5.0 }.should change(@subject, attr).from(value).to(value + 5)
      end
    end
  end

  FLOATS_WITH_DEVIATIONS.keys.each do |attr|
    describe "#{attr}=" do
      it "should set #{attr}" do
        @subject.send("#{attr}=", 42.0).should eq 42.0
        @subject.send("#{attr}").should eq 42.0
      end
    end

    describe "#{attr}_deviation=" do
      it "should set #{attr}_deviation" do
        @subject.send("#{attr}_deviation=", 42.0).should eq 42.0
        @subject.send("#{attr}_deviation").should eq 42.0
      end
    end
  end

  describe "draw" do
    it "should not draw anything if there aren't any particles'" do
      dont_allow(@subject.instance_variable_get(:@image)).draw_as_points
      @subject.draw
    end

    it "should draw all active particles" do
      image = @subject.instance_variable_get :@image
      mock(image).draw_rot_without_hash(1.0, 2.0, 3, 0..360, 0.5, 0.5, 1.0, 1.0,
                                        Gosu::Color::WHITE).times 3
      3.times { @subject.emit }
      @subject.draw
    end
  end

  describe "emit" do
    it "should create one more particle" do
      ->{ @subject.emit }.should change(@subject, :count).from(0).to(1)
    end

    it "should replace a particle if we are already at max particles" do
      (@default_max + 1).times { @subject.emit }
      @subject.count.should eq 100
    end
  end

  describe "update" do
    it "should emit a particle" do
      mock(@subject).emit
      @subject.update
    end
  end
end