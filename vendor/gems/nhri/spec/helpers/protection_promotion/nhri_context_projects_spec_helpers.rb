require 'rspec/core/shared_context'

module NhriContextProjectsSpecHelpers
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
    visit nhri_protection_promotion_projects_path(:en)
  end

  def set_file_defaults
    SiteConfig['project_document.filetypes'] = ['pdf']
    SiteConfig['project_document.filesize'] = 5
  end

  def heading_prefix
    "NHRI Protection and Promotion"
  end

  def project_model
    Nhri::ProtectionPromotion::Project
  end

  def populate_database
    ggp = FactoryGirl.create(:nhri_protection_promotion_project,
                             :with_documents,
                             :with_performance_indicators)

    ggp = FactoryGirl.create(:nhri_protection_promotion_project,
                             :with_named_documents,
                             :with_performance_indicators,
                             :with_mandates,
                             :with_project_types,
                             :with_agencies,
                             :with_conventions)
  end
end
