require_relative "../lib/ashton"

require "rspec"
require 'rspec/autorun'
require "rr"
require 'texplay'

RSpec.configure do |config|
  config.mock_framework = :rr
end

def media_path(file); File.expand_path "../examples/media/#{file}", File.dirname(__FILE__) end
