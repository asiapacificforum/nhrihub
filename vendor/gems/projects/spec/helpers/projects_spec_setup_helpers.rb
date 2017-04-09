require 'rspec/core/shared_context'

module ProjectsSpecSetupHelpers
  extend RSpec::Core::SharedContext
  before do
    setup_strategic_plan
    populate_mandates
    populate_types
    populate_database
    set_file_defaults
    visit projects_path(:en)
  end

  def set_file_defaults
    SiteConfig['project_document.filetypes'] = ['pdf']
    SiteConfig['project_document.filesize'] = 5
  end

  def populate_database
    FactoryGirl.create(:project,
                       :with_documents,
                       :with_performance_indicators)

    @project = FactoryGirl.create(:project,
                             :with_named_documents,
                             :with_performance_indicators,
                             :with_mandates,
                             :with_project_types,
                             :title => '" all? the<>\ [] ){} ({)888.,# weird // @;:characters &')
  end

  def populate_mandates
    ["good_governance", "human_rights", "special_investigations_unit", "corporate_services"].each do |key|
      Mandate.create(:key => key)
    end
  end

  def populate_types
    gg = Mandate.find_or_create_by(:key => 'good_governance')
    hr = Mandate.find_or_create_by(:key => 'human_rights')

    gg_types = [ "Consultation", "Awareness Raising"]
    gg_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => gg.id)
    end

    hr_types = ["Schools", "Amicus Curiae", "State of Human Rights Report"]
    hr_types.each do |type|
      ProjectType.create(:name => type, :mandate_id => hr.id)
    end
  end

  def setup_strategic_plan
    sp = StrategicPlan.create(:created_at => 6.months.ago.to_date, :title => "a plan for the millenium")
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    a1 = Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
    3.times do
      PerformanceIndicator.create(:description => Faker::Lorem.words(3).join(" "), :target => "90%", :activity_id => a1.id)
    end
    a2 = Activity.create(:description => "Public outreach", :outcome_id => o.id)
    3.times do
      PerformanceIndicator.create(:description => Faker::Lorem.words(3).join(" "), :target => "90%", :activity_id => a2.id)
    end
    a3 = Activity.create(:description => "Media coverage", :outcome_id => o.id)
    3.times do
      PerformanceIndicator.create(:description => Faker::Lorem.words(3).join(" "), :target => "90%", :activity_id => a3.id)
    end
  end
end

