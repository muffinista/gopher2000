# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gopher2000/version"

Gem::Specification.new do |s|
  s.name        = "gopher2000"
  s.version     = Gopher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Colin Mitchell"]
  s.email       = ["colin@muffinlabs.com"]
  s.homepage    = "https://github.com/muffinista/gopher2000"
  s.summary     = %q{Gopher2000 - A Gopher server for the next millenium}
  s.description = %q{Gopher2000 is a ruby-based Gopher server. It is built for speedy, enjoyable development of all sorts of gopher sites.}

  s.licenses = ["WTFPL"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "redcarpet"
  s.add_development_dependency "yard"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "simplecov", "~> 0.16.1"
  s.add_development_dependency "watchr"

  s.add_runtime_dependency "artii", ">= 2.0.1"
  s.add_runtime_dependency "eventmachine", "~> 1.2.5"
  s.add_runtime_dependency "logging"
  s.add_runtime_dependency "mimemagic"
end
