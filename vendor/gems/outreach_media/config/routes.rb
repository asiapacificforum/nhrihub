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
      resources :media_appearances do
        resources :reminders, :controller => "media_appearances/reminders"
        resources :notes, :controller => "media_appearances/notes"
      end
      resources :areas do
        resources :subareas
      end
    end
  end
end
