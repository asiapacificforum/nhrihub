module CorporateServices
  class Engine < Rails::Engine
    config.mount_at = '/'

    config.i18n.load_path += Dir.glob(config.root.join('config','locales','views','*.{rb,yml}'))

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
