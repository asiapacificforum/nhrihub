$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "outreach_media/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "outreach_media"
  s.version     = OutreachMedia::VERSION
  s.authors     = ["Les Nightingill"]
  s.email       = ["codehacker@comcast.net"]
  #s.homepage    = "TODO"
  s.summary     = "private gem, engine module for nhridocs app"
  s.description = "private gem, engine module for nhridocs app"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.0"

  s.add_development_dependency "sqlite3"
end
