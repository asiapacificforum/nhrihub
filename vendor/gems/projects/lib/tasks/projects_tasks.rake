namespace :projects do
  desc "populates all projects-related tables"
  task :populate => ["projects:populate_mandates", "projects:populate_types", "projects:populate_projects"]

  desc "populates the projects table"
  task "populate_projects" => :environment do
    Project.destroy_all
    5.times do
      FactoryGirl.create(:project, :with_reminders)
    end
  end

  desc "populates the mandates table"
  task :populate_mandates => :environment do
    Mandate.destroy_all
    ["good_governance", "human_rights", "special_investigations_unit", "corporate_services"].each do |key|
      Mandate.create(:key => key)
    end
  end

  desc "populates types for each mandate"
  task :populate_types => :environment do
    ProjectType.destroy_all
    gg = Mandate.find_or_create_by(:key => 'good_governance')
    hr = Mandate.find_or_create_by(:key => 'human_rights')
    siu = Mandate.find_or_create_by(:key => 'special_investigations_unit')
    corp = Mandate.find_or_create_by(:key => 'corporate_services')

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

  #desc "populates conventions"
  #task :populate_conv => :environment do
    #Convention.destroy_all
    ## CONVENTIONS defined in lib/constants
    #conventions = CONVENTIONS.each do |short,full|
      #Convention.create(:name => short, :full_name => full)
    #end
  #end
end
