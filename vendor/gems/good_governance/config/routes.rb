Rails.application.routes.draw do
  scope ':locale'  do
    namespace :good_governance do
      resources :internal_documents
    end
  end
end
