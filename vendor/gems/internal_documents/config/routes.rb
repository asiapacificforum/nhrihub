Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :internal_documents do
      resources :filetypes, :param => :ext, :only => [:create, :destroy]
      resource :filesize, :only => :update
    end
    resources :internal_documents
    resource :internal_document_admin, :only => :show, :to => 'internal_document_admin#show'
  end
end
