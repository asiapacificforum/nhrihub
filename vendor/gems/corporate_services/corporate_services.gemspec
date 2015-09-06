$:.push File.expand_path("../lib", __FILE__)

require "corporate_services/version"

Gem::Specification.new do |s|
  s.name        = "corporate_services"
  s.version     = CorporateServices::VERSION
  s.authors     = ["Les Nightingill"]
  s.email       = ["codehacker@comcast.net"]
  s.summary     = "private gem engine for nhridocs app"
  #s.files = Dir["{app,config,db,lib}/**/*"]
end
