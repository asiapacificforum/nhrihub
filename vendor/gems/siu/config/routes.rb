Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :siu do
      resources :internal_documents
    end
  end
end
