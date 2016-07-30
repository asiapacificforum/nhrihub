$:.push File.expand_path("../lib", __FILE__)

require "complaints/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "complaints"
  s.version     = Complaints::VERSION
  s.authors     = ["Les Nightingill"]
  s.email       = ["codehacker@comcast.net"]
  s.summary     = "private gem engine for nhridocs app"
end
