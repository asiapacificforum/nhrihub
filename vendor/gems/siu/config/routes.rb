Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :siu do
      resources :internal_documents
      resources :projects do
        resources :reminders, :controller => "project/reminders"
        resources :notes, :controller => "project/notes"
      end
      resources :projects
    end
  end
end
