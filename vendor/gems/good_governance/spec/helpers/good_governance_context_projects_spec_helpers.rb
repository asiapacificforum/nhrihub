require 'rspec/core/shared_context'

module GoodGovernanceContextProjectsSpecHelpers
  extend RSpec::Core::SharedContext
  before do
    setup_strategic_plan
    populate_mandates
    populate_types
    populate_agencies
    populate_conventions
    populate_database
    resize_browser_window
    visit good_governance_projects_path(:en)
  end

  def heading_prefix
    "Good Governance"
  end

  def project_model
    GoodGovernance::Project
  end

  def populate_database
    2.times do
      ggp = FactoryGirl.create(:good_governance_project)
      ggp.performance_indicator_ids = PerformanceIndicator.pluck(:id).shuffle.take(3)
      ggp.save
    end
    ggp = FactoryGirl.create(:good_governance_project)
    ggp.performance_indicator_ids = PerformanceIndicator.pluck(:id).shuffle.take(3)
    ggp.mandate_ids = Mandate.pluck(:id)
    ggp.project_type_ids = ProjectType.pluck(:id)
    ggp.agency_ids = Agency.pluck(:id)
    ggp.convention_ids = Convention.pluck(:id)
    ggp.save
  end
end
