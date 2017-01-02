$:.push File.expand_path("../lib", __FILE__)

require "issues_reporter/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "issues_reporter"
  s.version     = IssuesReporter::VERSION
  s.authors     = ["write your name here"]
  s.email       = ["write your email address here"]
  s.summary     = "private gem engine for nhridocs app"
end
