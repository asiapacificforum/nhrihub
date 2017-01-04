Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :internal_documents do
      file_attachment_concern
    end
    resources :internal_documents
    resource :internal_document_admin, :only => :show, :to => 'internal_document_admin#show'
  end
end
