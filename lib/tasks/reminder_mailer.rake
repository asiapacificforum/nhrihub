namespace :nhri_docs do
  desc "task to invoke daily from cron. Mails reminders that are due today"
  task :mail_reminders => :environment do
    Reminder.due_today.each(&:send)
  end
end

namespace :reminder do
  desc "create a reminder that is due today, that should be emailed with the nhri_docs:mail_reminders rake task"
  task :due_today => :environment do
    FactoryGirl.create(:reminder, :media_appearance, :due_today)
  end
end
