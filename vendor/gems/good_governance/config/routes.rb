Rails.application.routes.draw do
  scope ':locale'  do
    namespace :good_governance do
      resources :internal_documents
      resources :complaints
      resources :projects
    end
  end
end
