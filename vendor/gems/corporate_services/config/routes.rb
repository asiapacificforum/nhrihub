Rails.application.routes.draw do
  scope ":locale", locale: /en|fr/ do
    namespace :corporate_services do
      namespace :internal_documents do # note this must be before the internal documents resource
        resources :filetypes, :param => :type, :only => [:create, :destroy]
        resource :filesize, :only => :update
      end
      resources :internal_documents
      resources :performance_reviews
      namespace :strategic_plans do
        resource :start_date, :only => :update
      end
      resources :strategic_plans
      get 'admin', :to => "admin#index"
    end
  end
end
