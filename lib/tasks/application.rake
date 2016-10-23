desc "populate the entire application"
task :populate => :environment do
  Note.destroy_all
  Reminder.destroy_all
  ["csp_reports:populate", "projects:populate", "complaints:populate", "corporate_services:populate", "outreach_media:populate", "nhri:populate"].each do |task|
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

namespace :complaints do
  desc "populates all complaint-related tables"
  task :populate => [:populate_complaints]

  desc "populates complaints"
  task :populate_complaints => [:environment, :populate_complaint_bases, :populate_cats, 'projects:populate_mandates', 'projects:populate_agnc'] do
    Complaint.destroy_all
    3.times do |i|
      complaint = FactoryGirl.create(:complaint, :case_reference => "C16/#{i+1}")

      # avoid creating too many users... creates login collisions
      if User.count > 20
        assignees = User.all.sample(2)
      else
        assignees = [FactoryGirl.create(:assignee, :with_password), FactoryGirl.create(:assignee, :with_password)]
      end
      assigns = assignees.map do |user|
        date = DateTime.now.advance(:days => -rand(365))
        Assign.create(:created_at => date, :assignee => user)
      end
      complaint.assigns << assigns

      complaint_document = FactoryGirl.create(:complaint_document, :title => rand_title, :filename => rand_filename)
      complaint.complaint_documents << complaint_document

      complaint_category = ComplaintCategory.all.sample
      complaint.complaint_categories << complaint_category

      complaint.good_governance_complaint_bases << GoodGovernance::ComplaintBasis.all.sample(2)
      complaint.human_rights_complaint_bases << Nhri::ComplaintBasis.all.sample(2)
      complaint.special_investigations_unit_complaint_bases << Siu::ComplaintBasis.all.sample(2)
      complaint.status_changes << FactoryGirl.create(:status_change, :user_id => User.all.sample.id)
      complaint.mandate_ids = Mandate.pluck(:id).sample
      complaint.agency_ids = Agency.pluck(:id).sample(2)
    end
  end

  desc "populates complaint categories"
  task :populate_cats => :environment do
    ComplaintCategory.destroy_all
    ComplaintCategories.each do |category|
      ComplaintCategory.create(:name => category)
    end
  end

  desc "populates complaint bases for all mandates"
  task :populate_complaint_bases => :environment do
    ComplaintBasis.destroy_all
    Convention.destroy_all
    ["GoodGovernance", "Nhri", "Siu"].each do |type_prefix|
      klass = type_prefix+"::ComplaintBasis"
      klass.constantize::DefaultNames.each do |name|
        klass.constantize.create(:name => name)
      end
    end
  end
end
