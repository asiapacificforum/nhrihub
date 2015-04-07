require 'active_support/core_ext/hash/slice'
require "rails/generators/rails/app/app_generator"
require 'date'

module Rails
  class PluginBuilder

    def license
      # no license included in the module, the main app license covers the modules
    end

    def lib
      template "lib/%name%.rb"
      template "lib/tasks/%name%_tasks.rake"
      template "lib/%name%/version.rb"
      template "lib/%name%/engine.rb" if engine?
    end

    def config
      template "config/routes.rb" if engine?
    end
  end
end

require 'rails/generators'
require 'rails/generators/rails/plugin/plugin_generator'

class NhridocsModuleGenerator < Rails::Generators::NamedBase
  Rails::Generators::PluginGenerator.source_paths << File.expand_path('../templates', __FILE__)
  args = ["vendor/gems/"+ARGV[0], "--skip-bundle", "--skip-test-unit", "--full"]
  Rails::Generators::PluginGenerator.start(args)
end
