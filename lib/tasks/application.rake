desc "populate the entire application"
task :populate => :environment do
  Note.destroy_all
  Reminder.destroy_all
  modules = ["csp_reports", "projects", "complaints", "corporate_services", "media", "nhri", "internal_documents"]
  modules.each do |task|
    Rake::Task[task+":populate"].invoke
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
