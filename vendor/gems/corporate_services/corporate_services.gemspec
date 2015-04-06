$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "corporate_services/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "corporate_services"
  s.version     = CorporateServices::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of CorporateServices."
  s.description = "TODO: Description of CorporateServices."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.5"

  s.add_development_dependency "sqlite3"
end
