# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "huey/version"

Gem::Specification.new do |s|
  s.name        = "huey"
  s.version     = Huey::VERSION
  s.author      = "Veraticus"
  s.email       = "josh@joshsymonds.com"
  s.homepage    = "https://github.com/Veraticus/huey"
  s.summary     = "Quick and simple discovery and control of Phillips Hue lightbulbs"
  s.description = %q{Everything you could want for making Phillips Hue lightbulbs obey your every command.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = %w(LICENSE README.markdown)
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">=1.9.1")

  s.add_dependency('eventmachine', '>=1.0.0')
  s.add_dependency('httparty', '>=0.9.0')
  s.add_dependency('chronic', '>=0.9.0')
  s.add_dependency('color', '>= 1.4.1')

  s.add_development_dependency('bundler', '>=0')
  s.add_development_dependency('yard', '>=0.8.3')
  s.add_development_dependency('mocha', '>=0.13.1')
  s.add_development_dependency('webmock', '>=1.9.0')
end
