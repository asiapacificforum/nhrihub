module Notifier
  extend ActiveSupport::Concern

  included do
    after_commit :signup_notify, :on => :create # don't send email if user is not valid
    after_save :activate_notify, :if => :pending?
    after_save :forgotten_password_notify, :if => :recently_forgot_password?
    after_save :reset_password_notify, :if => :recently_reset_password?
    after_save :lost_token_notify, :if => :lost_token?
  end

  Notifications = [:signup_notify, :activate_notify, :forgotten_password_notify, :reset_password_notify, :lost_token_notify]
  Notifications.each do |notification|
    mailer_method = notification.to_s.gsub(/y$/,'ication')
    define_method notification do
      Authengine::UserMailer.send(mailer_method, self).deliver_now
    end
  end

  def complaint_assignment_notify(complaint)
    ::ComplaintMailer.complaint_assignment_notification(complaint).deliver_now
  end

end
