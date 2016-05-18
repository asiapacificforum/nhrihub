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
    set_file_defaults
    resize_browser_window
    visit good_governance_projects_path(:en)
  end

  def set_file_defaults
    SiteConfig.defaults['project_documents.filetypes'] = ['pdf']
    SiteConfig.defaults['project_documents.filesize'] = 5
  end

  def heading_prefix
    "Good Governance"
  end

  def project_model
    GoodGovernance::Project
  end

  def populate_database
    ggp = FactoryGirl.create(:good_governance_project,
                             :with_documents,
                             :with_performance_indicators)

    ggp = FactoryGirl.create(:good_governance_project,
                             :with_named_documents,
                             :with_performance_indicators,
                             :with_mandates,
                             :with_project_types,
                             :with_agencies,
                             :with_conventions)
  end
end
