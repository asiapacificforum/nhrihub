Rails.application.routes.draw do
  scope ":locale", locale: /en|fr/ do
    namespace :corporate_services do
      namespace :internal_documents do # note this must be before the internal documents resource
        resources :filetypes, :param => :type, :only => [:create, :destroy]
        resource :filesize, :only => :update
      end
      namespace :strategic_plans do
        resource :start_date, :only => :update
      end
      resources :internal_documents
      resources :performance_reviews
      resources :strategic_plans do
        resources :strategic_priorities, :to => 'strategic_plans/strategic_priorities'
      end
      resources :strategic_priorities do
        resources :planned_results, :to => 'strategic_priorities/planned_results'
      end
      get 'admin', :to => "admin#index"
    end
  end
end
