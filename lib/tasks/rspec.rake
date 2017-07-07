require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

# because rails must be reloaded between specs
# as the specs depend on rails configuration
desc "run request specs"
task :requests do
  puts `rspec spec/requests/browser_check_spec.rb`
  puts `rspec spec/requests/browser_check_fr_spec.rb`
  puts `rspec spec/requests/error_pages_spec.rb`
end

desc "run all model specs"
task :models => :spec
RSpec::Core::RakeTask.module_eval do
  def pattern
    "{,vendor/gems/*/}spec/models/**/*_spec.rb"
  end
end

desc "run the entire test suite except request specs"
task :default => :spec
RSpec::Core::RakeTask.module_eval do
  def pattern
    "{,vendor/gems/*/}spec/{features,models,mailers}/**/*_spec.rb"
  end
end

desc "javascript test shortcut"
task :js do
  `rm -rf tmp/cache/assets/sprockets/v3.0/`
  puts `RAILS_ENV=jstest rake teaspoon suite=default`
end
