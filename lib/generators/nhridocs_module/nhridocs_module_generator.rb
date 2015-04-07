require 'active_support/core_ext/hash/slice'
require "rails/generators/rails/app/app_generator"
require 'date'
require 'rails/generators'
require 'rails/generators/rails/plugin/plugin_generator'

module Rails
  module Generators
    class PluginGenerator < AppBase
      # uses the spec method in PluginBuilder, below
      def spec
        build(:spec)
      end
    end
  end

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
      empty_directory_with_keep_file "config/locales/models"
      empty_directory_with_keep_file "config/locales/views"
    end

    def app
      empty_directory_with_keep_file 'app/models'
      empty_directory_with_keep_file "app/controllers/#{name}"
      empty_directory_with_keep_file "app/views/#{name}"
      empty_directory_with_keep_file 'app/helpers'
      empty_directory_with_keep_file 'app/mailers'
      empty_directory_with_keep_file "app/assets/images/#{name}"
    end

    def spec
      template "spec/rails_helper.rb"
      template "spec/features/example_spec.rb"
      template "spec/models/example_spec.rb"
      empty_directory_with_keep_file "spec/helpers"
    end

  end
end


class NhridocsModuleGenerator < Rails::Generators::NamedBase
  Rails::Generators::PluginGenerator.source_paths << File.expand_path('../templates', __FILE__)
  args = ["vendor/gems/"+ARGV[0], "--skip-bundle", "--skip-test-unit", "--full"]
  Rails::Generators::PluginGenerator.start(args)
end
