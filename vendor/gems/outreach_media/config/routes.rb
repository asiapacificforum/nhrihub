Rails.application.routes.draw do
  #scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
  scope ':locale' do
    namespace :outreach_media do
      get 'admin', :to => "admin#index"
      resources :outreach
      resources :media
    end
  end
end
