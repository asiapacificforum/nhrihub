Rails.application.routes.draw do
  scope ':locale' do
    namespace :nhri do
      [:icc, :file_monitor].each do |namespace|
        namespace namespace do file_attachment_concern end
      end
      namespace :icc do # note this must be before the icc resource
        resources :accreditation_required_document_groups, :param => :title, :only => [:create, :destroy]
      end
      namespace :protection_promotion do
        resources :internal_documents
      end
      resources :indicators, :controller => 'heading/indicators'
      resources :indicators do
        notes_reminder_concern('indicator')
        resources :monitors, :controller => 'indicator/monitors'
        resources :file_monitors, :controller => 'indicator/file_monitors'
      end
      resources :headings do
        resources :indicators, :controller => 'heading/indicators'
        resources :human_rights_attributes, :controller => 'heading/human_rights_attributes'
      end
      namespace :advisory_council do
        resources :terms_of_references
        resources :members
        resources :minutes
        resources :issues
        resources :advisory_council_issues do
          notes_reminder_concern('advisory_council_issue')
        end
        [:terms_of_reference_version, :advisory_council_minutes, :advisory_council_issue].each do |namespace|
          namespace namespace do
            file_attachment_concern
          end
        end
      end
      resources :hr_protection
      resources :icc
      resources :icc_reference_documents do
        notes_reminder_concern('icc_reference_documents')
      end
      resources :accreditation_required_docs
      get 'admin', :to => "admin#index"
    end
  end
end
