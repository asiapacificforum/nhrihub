require 'rspec/core/shared_context'

module SiuContextProjectsSpecHelpers
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
    visit siu_projects_path(:en)
  end

  def set_file_defaults
    SiteConfig.defaults['project_documents.filetypes'] = ['pdf']
    SiteConfig.defaults['project_documents.filesize'] = 5
  end

  def heading_prefix
    "Special Investigations Unit"
  end

  def project_model
    Siu::Project
  end

  def populate_database
    ggp = FactoryGirl.create(:siu_project,
                             :with_documents,
                             :with_performance_indicators)

    ggp = FactoryGirl.create(:siu_project,
                             :with_named_documents,
                             :with_performance_indicators,
                             :with_mandates,
                             :with_project_types,
                             :with_agencies,
                             :with_conventions)
  end
end
