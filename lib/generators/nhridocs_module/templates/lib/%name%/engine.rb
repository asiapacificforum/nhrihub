module <%= camelized %>
  class Engine < ::Rails::Engine
    config.mount_at = '/'

    # include the locales translations from the module
    config.i18n.load_path += Dir.glob(config.root.join('config','locales','views','*.{rb,yml}'))

    # append module migrations to the main app
    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        app.config.paths["db/migrate"] << config.paths["db/migrate"].expanded
      end
    end
  end
end
