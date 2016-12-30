
namespace :complaints do
  desc "populates all complaint-related tables"
  task :populate => [:populate_complaints]

  desc "populates complaints"
  task :populate_complaints => [:environment, :populate_statuses, :populate_complaint_bases, 'projects:populate_mandates', 'projects:populate_agnc'] do
    Complaint.destroy_all
    3.times do |i|
      complaint = FactoryGirl.create(:complaint, :case_reference => "C16-#{3-i}")

      # avoid creating too many users... creates login collisions
      if User.count > 20
        assignees = User.all.sample(2)
      else
        assignees = [FactoryGirl.create(:assignee, :with_password), FactoryGirl.create(:assignee, :with_password)]
      end
      assigns = assignees.map do |user|
        date = DateTime.now.advance(:days => -rand(365))
        Assign.create(:created_at => date, :assignee => user, :complaint_id => complaint.id )
      end

      complaint_document = FactoryGirl.create(:complaint_document, :title => rand_title, :filename => rand_filename)
      complaint.complaint_documents << complaint_document
      complaint.good_governance_complaint_bases << GoodGovernance::ComplaintBasis.all.sample(2)
      complaint.human_rights_complaint_bases << Nhri::ComplaintBasis.all.sample(2)
      complaint.special_investigations_unit_complaint_bases << Siu::ComplaintBasis.all.sample(2)
      complaint.status_changes << FactoryGirl.create(:status_change, :open, :user_id => User.all.sample.id)
      complaint.mandate_id = Mandate.pluck(:id).sample(1)
      complaint.agency_ids = Agency.pluck(:id).sample(2)
    end
  end

  desc "populates status table"
  task :populate_statuses => :environment do
    ComplaintStatus.destroy_all
    ["Open", "Suspended", "Closed"].each do |name|
      ComplaintStatus.create(:name => name)
    end
  end

  desc "populates complaint bases for all mandates"
  task :populate_complaint_bases => :environment do
    #ComplaintBasis.destroy_all
    #Convention.destroy_all
    ["GoodGovernance", "Nhri", "Siu"].each do |type_prefix|
      klass = type_prefix+"::ComplaintBasis"
      klass.constantize::DefaultNames.each do |name|
        if klass.constantize.send(:where, "\"#{klass.constantize.table_name}\".\"name\"='#{name}'").length > 0
          complaint_basis = klass.constantize.send(:where, "\"#{klass.constantize.table_name}\".\"name\"='#{name}'").first
        else
          klass.constantize.create(:name => name)
        end
      end
    end
  end
end
