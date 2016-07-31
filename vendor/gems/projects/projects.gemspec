$:.push File.expand_path("../lib", __FILE__)

require "projects/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "projects"
  s.version     = Projects::VERSION
end
