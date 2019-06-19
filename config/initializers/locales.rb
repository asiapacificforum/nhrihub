  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
  I18n.load_path += Dir.glob(Rails.root.join("config","locales","**","*.yml"))
  I18n.load_path += Dir.glob(Rails.root.join("vendor","gems","**","config","locales","**","*.yml"))
  Rails.application.config.i18n.default_locale = I18n.default_locale = ENV['RAILS_I18N_LOCALE'] || :en
  I18n.available_locales = [:en, :fr]
