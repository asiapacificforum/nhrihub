class ComplaintMailer < ActionMailer::Base
  def complaint_assignment_notification(complaint)
    @recipient = complaint.current_assignee
    @complaint = complaint
    mail( :to => "#{@recipient.email}",
          :subject => t('.subject'),
          :date => Time.now,
          :from => "#{APPLICATION_NAME || "database"} Administrator<#{ADMIN_EMAIL}>"
        )
  end

end
