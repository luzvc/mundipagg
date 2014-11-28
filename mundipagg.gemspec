# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "mundipagg/version"

Gem::Specification.new do |s|
  s.name        = "better-mundipagg"
  s.version     = Mundipagg::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bruno Azisaka"]
  s.email       = ["bruno@azisaka.com.br"]
  s.homepage    = ""
  s.summary     = %q{Mundipagg Integration}
  s.description = %q{Gem to integrate with Mundipagg's webservice.}

  s.add_development_dependency "rspec", "~> 3.1.0"
  s.add_development_dependency "simplecov", "~> 0.9.0"
  s.add_dependency "activemodel"
  s.add_dependency "savon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

