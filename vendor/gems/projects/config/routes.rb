Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :projects do
      # insert your routes here
    end
    resources :projects
    resources :project_performance_indicators, :only => :destroy
    resources :projects do
      resources :reminders, :controller => 'project/reminders'
      resources :notes, :controller => 'project/notes'
    end
    namespace :project_document do
      resources :filetypes, :param => :ext, :only => [:create, :destroy]
      resource :filesize, :only => :update
    end
    resources :project_documents, :only => [:destroy, :show]
    resource :project_admin, :only => :show, :to => 'project_admin#show'
    namespace :good_governance do
      resources :project_types, :only => [:create, :destroy]
    end
    namespace :siu do
      resources :project_types, :only => [:create, :destroy]
    end
    namespace :human_rights do
      resources :project_types, :only => [:create, :destroy]
    end


  end
end
