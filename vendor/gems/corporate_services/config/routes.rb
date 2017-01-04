Rails.application.routes.draw do
  scope ":locale", locale: /en|fr/ do
    namespace :corporate_services do
      namespace :internal_documents do
        file_attachment_concern
      end
      namespace :strategic_plans do
        resource :start_date, :only => :update
      end
      resources :internal_documents
      resources :strategic_plans do
        resources :strategic_priorities, :controller => 'strategic_plans/strategic_priorities'
      end
      resources :strategic_priorities do
        resources :planned_results, :controller => 'strategic_priorities/planned_results'
      end
      resources :planned_results do
        resources :outcomes, :controller => 'planned_results/outcomes'
      end
      resources :outcomes do
        resources :activities, :controller => "outcomes/activities"
      end
      resources :activities do
        resources :performance_indicators, :controller => "activities/performance_indicators"
      end
      resources :performance_indicators do
        notes_reminder_concern('performance_indicators')
      end
      get 'admin', :to => "admin#index"
    end
  end
end
