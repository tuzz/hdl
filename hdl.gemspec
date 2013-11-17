require "./lib/hdl/base"

Gem::Specification.new do |s|
  s.name        = "hdl"
  s.version     = HDL.version
  s.summary     = "HDL"
  s.description = "A parser and emulator for a minimalist hardware description language."
  s.author      = "Chris Patuzzo"
  s.email       = "chris@patuzzo.co.uk"
  s.homepage    = "https://github.com/tuzz/hdl"
  s.files       = ["README.md"] + Dir["lib/**/*.*"]

  s.add_dependency "treetop"
  s.add_dependency "polyglot"
  s.add_dependency "boolean_simplifier"

  s.add_development_dependency "rspec"
end
