desc "populate the entire application"
task :populate => ["corporate_services:populate", "outreach_media:populate", "nhri:populate"]

namespace :projects do
  desc "populates all projects-related tables"
  task :populate => ["projects:populate_mandates", "projects:populate_types", "projects:populate_agnc", "projects:populate_conv"]

  desc "populates the mandates table"
  task :populate_mandates => :environment do
    Mandate.destroy_all
    ["good_governance", "human_rights", "special_investigations_unit"].each do |key|
      Mandate.create(:key => key)
    end
  end

  desc "populates types for each mandate"
  task :populate_types => :environment do
    ProjectType.destroy_all
    gg = Mandate.find_or_create_by(:key => 'good_governance')
    hr = Mandate.find_or_create_by(:key => 'human_rights')
    siu = Mandate.find_or_create_by(:key => 'special_investigations_unit')

    gg_types = ["Own motion investigation", "Consultation", "Awareness raising", "Other"]
    gg_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => gg.id)
    end

    hr_types = ["Schools", "Report or Inquiry", "Awareness Raising", "Legislative Review",
                "Amicus Curiae", "Convention Implementation", "UN Reporting", "Detention Facilities Inspection",
                "State of Human Rights Report", "Other"]
    hr_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => hr.id)
    end

    siu_types = ["PSU Review", "Report", "Inquiry", "Other"]
    siu_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => siu.id)
    end
  end

  desc "populates agencies"
  task :populate_agnc => :environment do
    Agency.destroy_all
    # AGENCIES defined in lib/constants
    agencies = AGENCIES.each do |short,full|
      Agency.create(:name => short, :full_name => full)
    end
  end

  desc "populates conventions"
  task :populate_conv => :environment do
    Convention.destroy_all
    # CONVENTIONS defined in lib/constants
    conventions = CONVENTIONS.each do |short,full|
      Convention.create(:name => short, :full_name => full)
    end
  end
end

namespace :complaints do
  desc "populates all complaint-related tables"
  task :populate => [:populate_complaints]

  desc "populates complaints"
  task :populate_complaints => [:environment, :populate_complaint_bases, :populate_cats] do
    Complaint.destroy_all
    3.times do |i|
      complaint = FactoryGirl.create(:complaint, :case_reference => "C16/#{i+1}")

      # avoid creating too many users... creates login collisions
      if User.count > 20
        assignees = User.all.sample(2)
      else
        assignees = [FactoryGirl.create(:assignee), FactoryGirl.create(:assignee)]
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
