
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_cache/version"

Gem::Specification.new do |spec|
  spec.name          = "ar-simple-cache"
  spec.version       = SimpleCache::VERSION
  spec.authors       = ["begaborn"]
  spec.email         = ["begaborn@gmail.com"]

  spec.summary       = %q{test.}
  spec.description   = %q{test.}
  spec.homepage      = "https://github.com/begaborn"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency('activerecord', '>= 4.2.0') 
  spec.add_dependency('activesupport', '>= 4.2.0')
  spec.add_dependency('dalli')
  spec.add_dependency('memcached', '~> 1.8.0')

  spec.add_development_dependency 'appraisal', '>= 0.3.8'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'mysql2', '>=0.4.4'
  #spec.add_development_dependency 'mysql2', '= 0.3.18'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
