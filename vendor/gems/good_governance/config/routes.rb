Rails.application.routes.draw do
  scope ':locale'  do
    namespace :good_governance do
      resources :internal_documents
      resources :complaints
      resources :projects do
        resources :reminders, :controller => "project/reminders"
        resources :notes, :controller => "project/notes"
      end
      resources :projects
    end
  end
end
