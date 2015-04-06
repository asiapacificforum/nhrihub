Rails.application.routes.draw do
  scope ":locale", locale: /en|fr/ do
    namespace :corporate_services do
      resources :internal_documents
      resources :performance_reviews
      resources :strategic_plan_documents
    end
  end
end
