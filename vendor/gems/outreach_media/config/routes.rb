Rails.application.routes.draw do
  #scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
  scope ':locale' do
    namespace :outreach_media do
      get 'admin', :to => "admin#index"
      resources :outreach
      namespace :media_appearances do
        resources :filetypes, :param => :type, :only => [:create, :destroy]
        resource :filesize, :only => :update
      end
      resources :media_appearances
    end
  end
end
