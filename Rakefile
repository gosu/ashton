require 'bundler/setup'

require 'rake/clean'
require 'rspec/core/rake_task'
require 'rake/extensiontask'
require 'yard'
require 'redcloth'
require 'launchy'

begin
  require 'devkit' # only used on windows
rescue LoadError
end


spec = Gem::Specification.load Dir['*.gemspec'].first

Gem::PackageTask.new spec do
end

Rake::ExtensionTask.new 'ashton', spec do |ext|
  RUBY_VERSION =~ /(\d+.\d+)/
  ext.lib_dir = "lib/ashton/#{$1}"
end

YARD::Rake::YardocTask.new

task :default => :spec
task :spec => :compile

RSpec::Core::RakeTask.new do |t|
end

desc "Open yard docs in browser"
task :browse_yard => :yard do
  Launchy.open "doc/index.html" rescue nil
end

desc "Create platform-specific compiled gem"
task :native_gem do
  Rake::Task["native"].invoke "gem"
end