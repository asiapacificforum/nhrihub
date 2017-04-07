require 'rspec/core/shared_context'

module ProjectsSpecSetupHelpers
  extend RSpec::Core::SharedContext
  before do
    setup_strategic_plan
    populate_mandates
    populate_types
    populate_database
    set_file_defaults
    resize_browser_window
    visit projects_path(:en)
  end

  def set_file_defaults
    SiteConfig['project_document.filetypes'] = ['pdf']
    SiteConfig['project_document.filesize'] = 5
  end

  def populate_database
    ggp = FactoryGirl.create(:project,
                             :with_documents,
                             :with_performance_indicators)

    @project = FactoryGirl.create(:project,
                             :with_named_documents,
                             :with_performance_indicators,
                             :with_mandates,
                             :with_project_types)
  end


  def populate_mandates
    ["good_governance", "human_rights", "special_investigations_unit", "corporate_services"].each do |key|
      Mandate.create(:key => key)
    end
  end

  def populate_types
    gg = Mandate.find_or_create_by(:key => 'good_governance')
    hr = Mandate.find_or_create_by(:key => 'human_rights')
    #siu = Mandate.find_or_create_by(:key => 'special_investigations_unit')

    #gg_types = ["Own motion investigation", "Consultation", "Awareness Raising", "Other"]
    gg_types = [ "Consultation", "Awareness Raising"]
    gg_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => gg.id)
    end

    #hr_types = ["Schools", "Report or Inquiry", "Awareness Raising", "Legislative Review",
                #"Amicus Curiae", "Convention Implementation", "UN Reporting", "Detention Facilities Inspection",
                #"State of Human Rights Report", "Other"]
    hr_types = ["Schools", "Amicus Curiae", "State of Human Rights Report"]
    hr_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => hr.id)
    end

    #siu_types = ["PSU Review", "Report", "Inquiry", "Other"]
    #siu_types.each do |type|
      #ProjectType.create(:name => type, :mandate_id => siu.id)
    #end
  end

  def setup_strategic_plan
    sp = StrategicPlan.create(:created_at => 6.months.ago.to_date, :title => "a plan for the millenium")
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    a1 = Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
    a2 = Activity.create(:description => "Public outreach", :outcome_id => o.id)
    a3 = Activity.create(:description => "Media coverage", :outcome_id => o.id)
    p1 = PerformanceIndicator.create(:description => "Happier people", :target => "90%", :activity_id => a1.id)
    p2 = PerformanceIndicator.create(:description => "More wealth", :target => "80%", :activity_id => a2.id)
    p3 = PerformanceIndicator.create(:description => "Greater justice", :target => "70%", :activity_id => a3.id)

    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something weird")
    o = Outcome.create(:planned_result_id => pr.id, :description => "All good things")
    a1 = Activity.create(:description => "Random acts of kindness", :outcome_id => o.id)
    p1 = PerformanceIndicator.create(:description => "Life is better", :target => "90%", :activity_id => a1.id)
  end
end

