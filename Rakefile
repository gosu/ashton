require 'rake/clean'
require 'rspec/core/rake_task'
require 'yard'
require 'redcloth'
require 'launchy'
require 'rubygems/package_task'


spec = Gem::Specification.load Dir['*.gemspec'].first

Gem::PackageTask.new spec do
end

YARD::Rake::YardocTask.new

task :default => :spec

RSpec::Core::RakeTask.new do |t|
end

desc "Open yard docs in browser"
task :browse_yard => :yard do
  Launchy.open "doc/index.html" rescue nil
end