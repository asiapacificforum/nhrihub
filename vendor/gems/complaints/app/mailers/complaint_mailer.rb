class ComplaintMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers
  def complaint_assignment_notification(complaint, assignee)
    @recipient = assignee
    @complaint = complaint
    @link = complaints_url('en','html',:case_reference => "#{complaint.case_reference}")
    mail( :to => "#{@recipient.email}",
          :subject => t('.subject'),
          :date => Time.now,
          :from => "#{APPLICATION_NAME || "database"} Administrator<#{ADMIN_EMAIL}>"
        )
  end

end
