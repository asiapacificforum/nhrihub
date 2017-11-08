
namespace :complaints do
  desc "populates all complaint-related tables"
  task :populate => [:populate_complaints]

  task :depopulate => :environment do
    Complaint.destroy_all
  end

  desc "populates complaints"
  task :populate_complaints => [ :populate_statuses, :populate_complaint_bases, 'projects:populate_mandates', 'projects:populate_agnc', "complaints:depopulate"] do
    n = 50
    n.times do |i|
      complaint = FactoryGirl.create(:complaint, :with_associations, :with_assignees, :with_document, :with_comm, :with_reminders, :with_notes, :case_reference => "C17-#{n-i}")
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
