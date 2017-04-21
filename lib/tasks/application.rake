desc "populate the entire application"
task :populate => :environment do
  Note.destroy_all
  Reminder.destroy_all
  ["csp_reports:populate", "projects:populate", "complaints:populate", "corporate_services:populate", "media:populate", "nhri:populate"].each do |task|
    Rake::Task[task].invoke
  end
end

namespace :csp_reports do
  desc "populates some csp reports"
  task :populate => :environment do
    CspReport.destroy_all
    5.times do
      FactoryGirl.create(:csp_report)
    end
  end
end
