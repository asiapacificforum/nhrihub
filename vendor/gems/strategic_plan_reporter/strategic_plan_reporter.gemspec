$:.push File.expand_path("../lib", __FILE__)

require "strategic_plan_reporter/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "strategic_plan_reporter"
  s.version     = StrategicPlanReporter::VERSION
  s.authors     = ["write your name here"]
  s.email       = ["write your email address here"]
  s.summary     = "private gem engine for nhridocs app"
end
