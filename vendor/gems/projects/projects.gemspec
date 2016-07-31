$:.push File.expand_path("../lib", __FILE__)

require "projects/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "projects"
  s.version     = Projects::VERSION
  s.authors     = ["Les Nightingill"]
  s.email       = ["codehacker@comcast.net"]
  s.summary     = "private gem engine for nhridocs app"
end
