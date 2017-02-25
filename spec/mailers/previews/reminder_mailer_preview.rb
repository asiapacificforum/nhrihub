# Preview all emails at http://localhost:3000/rails/mailers/reminder_mailer
class ReminderMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/reminder
  def reminder
    ReminderMailer.reminder(Reminder.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/performance_indicator_reminder
  def performance_indicator_reminder
    reminder = PerformanceIndicator.first.reminders.first
    ReminderMailer.reminder(reminder)
  end

  # Preview this email at http://localhost:3000/rails/mailers/reminder_mailer/complaint
  def complaint_reminder
    reminder = Complaint.first.reminders.first
    ReminderMailer.reminder(reminder)
  end

  def icc_reference_document_reminder
    reminder = IccReferenceDocument.first.reminders.first
    ReminderMailer.reminder(reminder)
  end

  def advisory_council_issue_reminder
    reminder = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.reminders.first
    ReminderMailer.reminder(reminder)
  end

  def indicator_reminder
    reminder = Nhri::Indicator.first.reminders.first
    ReminderMailer.reminder(reminder)
  end

  def media_appearance_reminder
    reminder = MediaAppearance.first.reminders.first
    ReminderMailer.reminder(reminder)
  end

  def project_reminder
    reminder = Project.first.reminders.first
    ReminderMailer.reminder(reminder)
  end
end
