
require File.expand_path("../../helper.rb", __FILE__)

describe Ashton::ParticleEmitter do
  before :all do
    $window ||= Gosu::Window.new 16, 16, false
  end

  before :each do
    @subject = described_class.new 1, 2, 3
  end

  describe "initialize" do
    [:x, :y, :z].each.with_index(1) do |attr, value|
      it "should set #{attr}" do
        @subject.send(attr).should be_kind_of Float
        @subject.send(attr).should eq value
      end
    end

    it "should be set max_particles correctly" do
      @subject.max_particles.should be_kind_of Fixnum
      @subject.max_particles.should eq 1000
    end
  end

  [:x, :y, :z].each.with_index(1) do |attr, value|
    describe "#{attr}=" do
      it "should set the value of #{attr}" do
        @subject.send "#{attr}=", value + 5.0
        @subject.send(attr).should eq value + 5.0
      end
    end
  end

  describe "deviate" do
    it "should generate numbers within deviation" do
      100.times do
        @subject.send(:deviate, 100.0, 0.5).should be >= 50
        @subject.send(:deviate, 100.0, 0.5).should be < 150
      end
    end
  end
end