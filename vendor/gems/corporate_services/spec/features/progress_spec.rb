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
    setup_outreach_events
    setup_media_appearances
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "associated outreach_events and media_appearances should be shown" do
    outreach_text = OutreachEvent.first.title
    media_text = MediaAppearance.first.title
    expect(page).to have_selector(progress_selector + ".title.media span", :text => media_text)
    expect(page).to have_selector(progress_selector + ".title.outreach span", :text => outreach_text)
  end
end
