require File.expand_path("../../../helper.rb", __FILE__)

describe Gosu::Window do
  before :all do
    $window ||= Gosu::Window.new 16, 16, false
  end

  describe "post_process" do
    pending
  end
end