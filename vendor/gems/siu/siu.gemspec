$:.push File.expand_path("../lib", __FILE__)

require "siu/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "siu"
  s.version     = Siu::VERSION
  s.authors     = ["Les Nightingill"]
  s.email       = ["codehacker@comcast.net"]
  s.summary     = "private gem engine for nhridocs app"
end
