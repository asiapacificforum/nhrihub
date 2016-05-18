Rails.application.routes.draw do
  scope ':locale'  do
    namespace :good_governance do
      namespace :project_document do
        resources :filetypes, :param => :ext, :only => [:create, :destroy]
        resource :filesize, :only => :update
      end
      resources :internal_documents
      resources :complaints
      resources :projects do
        resources :reminders, :controller => "project/reminders"
        resources :notes, :controller => "project/notes"
      end
      resources :projects
      get 'admin', :to => "admin#index"
    end
  end
end
