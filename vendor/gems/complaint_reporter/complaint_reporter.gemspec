$:.push File.expand_path("../lib", __FILE__)

require "complaint_reporter/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "complaint_reporter"
  s.version     = ComplaintReporter::VERSION
  s.authors     = ["write your name here"]
  s.email       = ["write your email address here"]
  s.summary     = "private gem engine for nhridocs app"
end
