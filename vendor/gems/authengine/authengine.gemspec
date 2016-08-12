# -*- encoding: utf-8 -*-
# stub: authengine 0.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "authengine"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Les Nightingill"]
  s.date = "2014-01-13"
  s.description = "A rails authentication and authorization engine that\n                    reduces clutter in your controllers and views.\n                    Includes aliased link_to and button_to helpers that return an empty string\n                    if the current user is not permitted to follow the link.\n                    Authorization configuration is removed from the controllers and instead\n                    is stored in the database and configured through html views."
  s.email = ["codehacker@comcast.net"]
  s.files         = `git ls-files`.split("\n")
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubyforge_project = "authengine"
  s.rubygems_version = "2.1.11"
  s.summary = "Unobtrusive authentication and authorization engine"
  s.test_files = ["spec/authengine_spec.rb", "spec/dummy/.rspec", "spec/dummy/Gemfile", "spec/dummy/Rakefile", "spec/dummy/app/assets/javascripts/jasmine_examples/Player.js", "spec/dummy/app/assets/javascripts/jasmine_examples/Song.js", "spec/dummy/app/controllers/application_controller.rb", "spec/dummy/app/helpers/application_helper.rb", "spec/dummy/app/views/layouts/application.html.erb", "spec/dummy/config.ru", "spec/dummy/config/application.rb", "spec/dummy/config/boot.rb", "spec/dummy/config/database.yml", "spec/dummy/config/environment.rb", "spec/dummy/config/environments/development.rb", "spec/dummy/config/environments/production.rb", "spec/dummy/config/environments/test.rb", "spec/dummy/config/initializers/application.rb", "spec/dummy/config/initializers/backtrace_silencers.rb", "spec/dummy/config/initializers/inflections.rb", "spec/dummy/config/initializers/mime_types.rb", "spec/dummy/config/initializers/secret_token.rb", "spec/dummy/config/initializers/session_store.rb", "spec/dummy/config/locales/en.yml", "spec/dummy/config/routes.rb", "spec/dummy/db/development.sqlite3", "spec/dummy/db/migrate/20121108140828_create_authengine_tables.authengine_engine.rb", "spec/dummy/db/migrate/20121108140829_add_parent_id_to_roles_table.authengine_engine.rb", "spec/dummy/db/migrate/20121108140830_add_type_field_to_user_roles_table.authengine_engine.rb", "spec/dummy/db/migrate/20121108140831_add_indexes_to_several_tables.authengine_engine.rb", "spec/dummy/db/migrate/20121108140832_add_organizations_table.authengine_engine.rb", "spec/dummy/db/migrate/20121108140833_add_organization_id_to_users_table.authengine_engine.rb", "spec/dummy/db/migrate/20130302000835_add_pantry_and_referrer_fields_to_organizations_table.rb", "spec/dummy/db/migrate/20130430043717_remove_type_field_from_user_roles_table.authengine_engine.rb", "spec/dummy/db/schema.rb", "spec/dummy/lib/constants.rb", "spec/dummy/log/development.log", "spec/dummy/log/production.log", "spec/dummy/log/server.log", "spec/dummy/public/404.html", "spec/dummy/public/422.html", "spec/dummy/public/500.html", "spec/dummy/public/favicon.ico", "spec/dummy/public/javascripts/application.js", "spec/dummy/public/javascripts/controls.js", "spec/dummy/public/javascripts/dragdrop.js", "spec/dummy/public/javascripts/effects.js", "spec/dummy/public/javascripts/prototype.js", "spec/dummy/public/javascripts/rails.js", "spec/dummy/public/stylesheets/.gitkeep", "spec/dummy/script/rails", "spec/dummy/spec/javascripts/helpers/.gitkeep", "spec/dummy/spec/javascripts/helpers/SpecHelper.js", "spec/dummy/spec/javascripts/jasmine_examples/PlayerSpec.js", "spec/dummy/spec/javascripts/support/jasmine.yml", "spec/generators/authengine_generator_spec.rb", "spec/integration/navigation_spec.rb", "spec/javascripts/spec.css", "spec/javascripts/spec.js.coffee", "spec/models/action_role_spec.rb", "spec/models/authenticated_system_spec.rb", "spec/models/organization_spec.rb", "spec/models/role_spec.rb", "spec/models/user_factory_spec.rb", "spec/models/user_spec.rb", "spec/requests/sessions_spec.rb", "spec/spec_helper.rb"]

  #s.add_runtime_dependency("rspec", [">= 2.0.0"])
  #s.add_runtime_dependency("rails", [">= 4.2.0"])
  s.add_runtime_dependency("rails", "5.0.0")
  s.add_runtime_dependency("sqlite3")
  s.add_runtime_dependency("capybara")
  s.add_runtime_dependency("rspec-rails", [">= 2.0.0"])
  s.add_runtime_dependency("faker")
  s.add_runtime_dependency("message_block")
  s.add_runtime_dependency("haml")
  s.add_runtime_dependency("factory_girl_rails")
  s.add_runtime_dependency("database_cleaner")
  # required in Rails4, observers were moved into this gem
  # it's in Gemspec now b/c it's sourced at github
  #s.add_runtime_dependency "rails-observers", :git => "git@github.com:rails/rails-observers.git"
end
