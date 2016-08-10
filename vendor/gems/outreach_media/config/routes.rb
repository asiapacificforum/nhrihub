Rails.application.routes.draw do
  #scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
  scope ':locale' do
    namespace :outreach_media do
      get 'admin', :to => "admin#index"
      resources :filetypes, :param => :ext, :only => [:create, :destroy]
      resource :filesize, :only => :update
      resources :audience_types
      resources :media_appearances do
        resources :media_appearance_performance_indicators, :controller => "media_appearances/performance_indicators", :only => :destroy
        resources :reminders, :controller => "media_appearances/reminders"
        resources :notes, :controller => "media_appearances/notes"
      end
      resources :outreach_events do
        resources :outreach_event_performance_indicators, :controller => "outreach_events/performance_indicators", :only => :destroy
        resources :reminders, :controller => "outreach_events/reminders"
        resources :notes, :controller => "outreach_events/notes"
        resources :outreach_event_documents, :controller => "outreach_events/outreach_event_documents", :only => [:destroy,:show]
      end
      resources :areas do
        resources :subareas
      end
    end
  end
end
