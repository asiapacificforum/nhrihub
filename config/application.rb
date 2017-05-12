require File.expand_path('../boot', __FILE__)
begin
  require File.expand_path('../../lib/constants', __FILE__)
rescue LoadError
end

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require File.expand_path('../../lib/rails_class_extensions', __FILE__)
require File.expand_path('../../lib/ruby_class_extensions', __FILE__)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Apf
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = TIME_ZONE

    begin
      config.action_mailer.default_url_options = {:host => SITE_URL}
    rescue NameError
      config.action_mailer.default_url_options = {:host => "not_configured"}
    end
    config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

    # see http://railsapps.github.io/rails-environment-variables.html
    config.before_configuration do
      env_file = File.join(Rails.root, 'config', 'env.yml')
      YAML.load(File.open(env_file)).each do |key, value|
        ENV[key.to_s] = value
      end if File.exists?(env_file)
    end
  end

end
