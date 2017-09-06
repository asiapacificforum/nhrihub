Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    [:communication_document, :complaint_document].each do |namespace|
      namespace namespace do file_attachment_concern end # see lib/file_attachment_concern.rb
    end
    resources :communication_documents, :only => [:destroy, :show]
    resources :complaint_documents, :only => [:destroy, :show]
    resource :complaint_admin, :only => :show, :to => 'complaint_admin#show'
    resources :complaints
    resources :complaints do
      notes_reminder_concern('complaint')
      resources :communications, :controller => "complaint/communications"
    end
    resources :good_governance_complaint_bases, :only => [:create, :destroy], :controller => 'good_governance/complaint_bases'
    resources :siu_complaint_bases, :only => [:create, :destroy], :controller => 'siu/complaint_bases'
    resources :strategic_plan_complaint_bases, :only => [:create, :destroy], :controller => 'strategic_plans/complaint_bases'
    resources :agencies, :only => [:create, :destroy]
  end
end
