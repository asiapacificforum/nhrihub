module FileAttachmentConcern
  def file_attachment_concern
    resources :filetypes, :param => :ext, :only => [:create, :destroy]
    resource :filesize, :only => :update
  end

  def notes_reminder_concern(controller)
    resources :reminders, :controller => "#{controller}/reminders"
    resources :notes, :controller => "#{controller}/notes"
  end
end
