require File.expand_path('lib/ashton/version', File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name = 'ashton'
  s.version = Ashton::VERSION
  s.date = Time.now.strftime '%Y-%m-%d'
  s.authors = ['Bil Bas']

  s.summary = 'Extra special effects, such as shader, for the Gosu game-development library'
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

  s.add_dependency 'opengl', '~> 0.8.0.pre1'

  s.add_development_dependency 'rspec', '~> 2.10.0'
  s.add_development_dependency 'rr', '~> 1.0.4'
  s.add_development_dependency 'launchy', '~> 2.1.0'
  s.add_development_dependency 'RedCloth', '~> 4.2.9'
  s.add_development_dependency 'redcarpet', '~> 2.1.1'
  s.add_development_dependency 'yard', '~> 0.8.2.1'
  s.add_development_dependency 'texplay', '~> 0.3'
end