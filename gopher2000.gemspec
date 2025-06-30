# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'gopher2000/version'

Gem::Specification.new do |s|
  s.name        = 'gopher2000'
  s.version     = Gopher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Colin Mitchell']
  s.email       = ['colin@muffinlabs.com']
  s.homepage    = 'https://github.com/muffinista/gopher2000'
  s.summary     = 'Gopher2000 - A Gopher server for the next millenium'
  s.description = 'Gopher2000 is a ruby-based Gopher server. It is built for speedy, enjoyable development of all sorts of gopher sites.'

  s.licenses = ['WTFPL']

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'artii', '>= 2.0.1'
  s.add_dependency 'logging'
  s.add_dependency 'mimemagic'
  s.add_dependency 'nio4r'
  s.add_dependency 'syslog'
  s.metadata['rubygems_mfa_required'] = 'true'
end
