# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'sponges/version'

Gem::Specification.new do |s|
  s.name          = "sponges"
  s.version       = Sponges::VERSION
  s.authors       = ["chatgris"]
  s.email         = ["jboyer@af83.com"]
  s.homepage      = "https://github.com/AF83/sponges"
  s.summary       = "Turn any ruby object to a daemon controlling an army of sponges."
  s.description   = "When I build workers, I want them to be like an army of spongebobs, always stressed and eager to work. sponges helps you build this army of sponges, to control them, and, well, to kill them gracefully. Making them stressed and eager to work is your job. :)"
  s.files         = `git ls-files lib LICENSE README.md`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.add_dependency "boson"
  s.add_dependency "nest"
  s.add_dependency "machine"
  s.add_development_dependency 'rspec', '~>2.10.0'
end
