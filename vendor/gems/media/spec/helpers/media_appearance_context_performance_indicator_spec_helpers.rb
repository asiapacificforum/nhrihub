require 'rspec/core/shared_context'

module MediaAppearanceContextPerformanceIndicatorSpecHelper
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_strategic_plan
    setup_database(:media_appearance_with_file)
    visit media_appearances_path(:en)
    @model = MediaAppearance
    @association = MediaAppearancePerformanceIndicator
    sleep(0.4)
  end

  def edit_first_item
    edit_article[0].click
  end

  def add_new_item
    add_article_button.click
  end
end
