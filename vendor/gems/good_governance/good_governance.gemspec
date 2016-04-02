$:.push File.expand_path("../lib", __FILE__)

require "good_governance/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "good_governance"
  s.version     = GoodGovernance::VERSION
  s.authors     = ["Les Nightingill"]
  s.email       = ["codehacker@comcast.net"]
  s.summary     = "private gem engine for nhridocs app"
end
