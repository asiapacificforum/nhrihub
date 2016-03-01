Rails.application.routes.draw do
  scope ':locale' do
    namespace :nhri do
      namespace :icc do # note this must be before the icc resource
        resources :accreditation_required_document_groups, :param => :title, :only => [:create, :destroy]
        resource  :filesize, :only => :update
        resources :filetypes, :param => :ext, :only => [:create, :destroy]
      end
      resources :hr_education
      namespace :advisory_council do
        resources :terms_of_references
        resources :members
        resources :minutes
        resources :issues
        namespace :terms_of_reference_version do
          resource  :filesize, :only => :update
          resources :filetypes, :param => :ext, :only => [:create, :destroy]
        end
        namespace :advisory_council_minutes do
          resource  :filesize, :only => :update
          resources :filetypes, :param => :ext, :only => [:create, :destroy]
        end
        namespace :advisory_council_issue do
          resource  :filesize, :only => :update
          resources :filetypes, :param => :ext, :only => [:create, :destroy]
        end
      end
      resources :nhr_indicators
      resources :hr_protection
      resources :icc
      resources :icc_reference_documents do
        resources :reminders, :controller => "icc_reference_documents/reminders"
      end
      resources :accreditation_required_docs
      get 'admin', :to => "admin#index"
    end
  end
end
