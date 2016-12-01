require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/performance_indicators_spec_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/setup_helpers'
require_relative '../helpers/progress_spec_helpers'


feature "performance indicators outreach events and media appearances", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include PerformanceIndicatorsSpecHelpers
  include StrategicPlanHelpers
  include SetupHelpers
  include ProgressSpecHelpers

  before do
    setup_strategic_plan
    setup_media_appearances
    setup_projects
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "associated outreach_events and media_appearances should be shown" do
    media_text = MediaAppearance.first.title
    project_text = Project.first.title
    expect(page).to have_selector(progress_selector + ".title.media_appearance span", :text => media_text)
    expect(page).to have_selector(progress_selector + ".title.project span", :text => project_text)
  end
end
