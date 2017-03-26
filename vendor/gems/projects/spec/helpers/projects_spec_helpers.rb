require 'rspec/core/shared_context'

module ProjectsSpecHelpers
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

end
