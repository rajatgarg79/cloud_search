# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloud_search/version'

Gem::Specification.new do |gem|
  gem.name          = "cloud_search"
  gem.version       = CloudSearch::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["Willian Fernandes"]
  gem.email         = ["willian@willianfernandes.com.br"]
  gem.homepage      = "http://rubygems.org/gems/cloud_search"
  gem.summary       = "A wraper to Amazon CloudSearch's API"
  gem.description   = gem.summary

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"     , "~> 2.11"
  gem.add_development_dependency "simplecov" , "~> 0.6"
  gem.add_development_dependency "vcr"       , "~> 2.2"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "guard"
  gem.add_development_dependency "guard-rspec"
  gem.add_development_dependency "rb-fsevent"

  gem.add_dependency "em-http-request"       , "~> 1.0"
end

