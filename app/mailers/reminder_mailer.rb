class ReminderMailer < ApplicationMailer
  default from: "#{APPLICATION_NAME || "database"} Administrator<#{NO_REPLY_EMAIL}>"

  # Subject set in en.reminder_mailer.reminder.subject
  def reminder(reminder)
    @recipients = reminder.user.first_last_name
    @text = reminder.text
    mail to: reminder.user.email_with_name, subject: default_i18n_subject(application_name: APPLICATION_NAME)
  end
end
