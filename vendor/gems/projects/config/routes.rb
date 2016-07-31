Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :projects do
      # insert your routes here
    end
  end
end
