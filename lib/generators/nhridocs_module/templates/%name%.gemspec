$:.push File.expand_path("../lib", __FILE__)

require "<%= name %>/version"

# Absolute minimum gemspec
Gem::Specification.new do |s|
  s.name        = "<%= name %>"
  s.version     = <%= camelized %>::VERSION
end
