
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_cache/version"

Gem::Specification.new do |spec|
  spec.name          = "ar-simple-cache"
  spec.version       = SimpleCache::VERSION
  spec.authors       = ["begaborn"]
  spec.email         = ["begaborn@gmail.com"]

  spec.summary       = "Easy Memcache Caching for ActiveRecord Association"
  spec.description   = "Simple Cache put your model objects associated with a base model into Memcached"
  spec.homepage      = "https://github.com/begaborn"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_dependency('activerecord', '>= 4.2.0')
  spec.add_dependency('activesupport', '>= 4.2.0')
  spec.add_dependency('dalli')

  spec.add_development_dependency 'appraisal', '>= 0.3.8'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'mysql2', '>=0.4.4'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
end
