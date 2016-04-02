Rails.application.routes.draw do
  scope ':locale'  do
    namespace :good_governance do
      resources :documents
      resources :complaints
      resources :projects
    end
  end
end
