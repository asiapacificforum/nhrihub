class ReminderMailer < ApplicationMailer
  default from: "#{APPLICATION_NAME || "database"} Administrator<#{NO_REPLY_EMAIL}>"

  # Subject set in en.reminder_mailer.reminder.subject
  def reminder(reminder)
    @recipients = reminder.users.map(&:first_last_name).join(", ")
    @text = reminder.text
    mail to: reminder.users.map(&:email_with_name), subject: default_i18n_subject(application_name: APPLICATION_NAME)
  end
end
