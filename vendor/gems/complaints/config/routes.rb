Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :complaints do
      # insert your routes here
    end
    namespace :complaint_document do
      resources :filetypes, :param => :ext, :only => [:create, :destroy]
      resource :filesize, :only => :update
    end
    resources :complaint_documents, :only => [:destroy, :show]
    resource :complaint_admin, :only => :show, :to => 'complaint_admin#show'
    resources :complaints
    resources :complaints do
      resources :reminders, :controller => "complaint/reminders"
      resources :notes, :controller => "complaint/notes"
      resources :communications, :controller => "complaint/communications"
    end
    resources :good_governance_complaint_bases, :only => [:create, :destroy], :controller => 'good_governance/complaint_bases'
    resources :siu_complaint_bases, :only => [:create, :destroy], :controller => 'siu/complaint_bases'
    resources :corporate_services_complaint_bases, :only => [:create, :destroy], :controller => 'corporate_services/complaint_bases'
  end
end
