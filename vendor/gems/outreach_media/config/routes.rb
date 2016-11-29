Rails.application.routes.draw do
  scope ':locale' do
    namespace :media_appearance do
      get 'admin', :to => "admin#index"
      resources :filetypes, :param => :ext, :only => [:create, :destroy]
      resource :filesize, :only => :update
      resources :media_appearance_performance_indicators, :controller => "media_appearances/performance_indicators", :only => :destroy
      resources :areas do
        resources :subareas
      end
    end
    resources :media_appearances do
      resources :reminders, :controller => "media_appearance/reminders"
      resources :notes, :controller => "media_appearance/notes"
    end
  end
end
