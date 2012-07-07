require 'rake/clean'
require 'rspec/core/rake_task'
require 'yard'
require 'redcloth'
require 'launchy'
require 'rubygems/package_task'


require File.expand_path('../lib/ashton/version', __FILE__)

# somewhere in your Rakefile, define your gem spec
spec = Gem::Specification.new do |s|
  s.name = 'ashton'
  s.version = Ashton::VERSION
  s.date = Time.now.strftime '%Y-%m-%d'
  s.authors = ['Bil Bas']

  s.summary = 'Extra special effects, such as shaders, for Gosu'
  s.description = <<-END
#{s.summary}
  END

  s.email = %w<bil.bagpuss@gmail.com>
  s.files = Dir.glob %w<CHANGELOG LICENSE Rakefile README.md lib/**/*.* lib examples/**/*.*>
  s.homepage = 'https://github.com/spooner/ashton'
  s.licenses = %w<MIT>
  s.rubyforge_project = 'ashton'
  s.test_files = []
  s.has_rdoc = 'yard'

  s.add_development_dependency 'rspec', '~> 2.10.0'
  s.add_development_dependency 'launchy', '~> 2.1.0'
end

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