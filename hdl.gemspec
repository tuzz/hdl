Gem::Specification.new do |s|
  s.name        = "hdl"
  s.version     = "0.0.0.alpha"
  s.summary     = "HDL"
  s.description = "A simple parser for a minimalist hardware description language."
  s.author      = "Chris Patuzzo"
  s.email       = "chris@patuzzo.co.uk"
  s.homepage    = "https://github.com/cpatuzzo/hdl"
  s.files       = ["README.md"] + Dir["lib/**/*.*"]

  s.add_dependency "treetop"
  s.add_dependency "polyglot"

  s.add_development_dependency "rspec"
end
