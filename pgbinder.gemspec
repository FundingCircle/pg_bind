# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)
require 'pgbinder/version'

Gem::Specification.new do |spec|
  spec.name          = 'pgbinder'
  spec.version       = PGBinder::VERSION
  spec.authors       = ['Giuseppe Lobraico']
  spec.email         = ['giuseppe.lobraico@fundingcircle.com']

  spec.summary       = 'PostgreSQL version manager, using Docker.'
  spec.description   = 'PostgreSQL version manager, using Docker.'
  spec.homepage      = 'http://github.com/FundingCircle/pgbinder'
  spec.license       = 'BSD-3'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'Set to http://mygemserver.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = ['pgbinder']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
end
