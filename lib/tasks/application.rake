desc "populate the entire application"
task :populate => :environment do
  Note.destroy_all
  Reminder.destroy_all
  modules = ["users", "csp_reports", "projects", "complaints", "strategic_plan", "media", "nhri", "internal_documents"]
  modules.each do |mod|
    Rake::Task[mod+":populate"].invoke
  end
end


desc "remove user-added data and wipes database ready for 'go-live'"
task :depopulate => :environment do
  Note.destroy_all
  Reminder.destroy_all
  modules = ["users", "csp_reports", "projects", "complaints", "strategic_plan", "media", "nhri", "internal_documents"]
  modules.each do |mod|
    Rake::Task[mod+":depopulate"].invoke
  end
end

namespace :csp_reports do
  desc "populates some csp reports"
  task :populate => "csp_reports:depopulate" do
    5.times do
      FactoryGirl.create(:csp_report)
    end
  end

  desc "removes all csp reports"
  task :depopulate => :environment do
    CspReport.destroy_all
  end
end
