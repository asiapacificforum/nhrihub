Rails.application.routes.draw do
  #scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
  scope ':locale' do
    namespace :outreach_media do
      resources :outreach
      resources :media
    end
  end
end
