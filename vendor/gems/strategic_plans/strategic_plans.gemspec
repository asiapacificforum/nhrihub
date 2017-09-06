$:.push File.expand_path("../lib", __FILE__)

require "strategic_plans/version"

Gem::Specification.new do |s|
  s.name        = "strategic_plans"
  s.version     = StrategicPlans::VERSION
  s.authors     = ["Les Nightingill"]
  s.email       = ["codehacker@comcast.net"]
  s.summary     = "private gem engine for nhridocs app"
  #s.files = Dir["{app,config,db,lib}/**/*"]
end
