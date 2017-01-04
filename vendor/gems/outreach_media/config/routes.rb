Rails.application.routes.draw do
  scope ':locale' do
    namespace :media_appearance do
      get 'admin', :to => "admin#index"
      file_attachment_concern
      resources :media_appearance_performance_indicators, :controller => "media_appearances/performance_indicators", :only => :destroy
      resources :areas do
        resources :subareas
      end
    end
    resources :media_appearances do
      notes_reminder_concern('media_appearance')
    end
  end
end
