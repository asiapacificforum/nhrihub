require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/performance_indicators_spec_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/setup_helpers'
require_relative '../helpers/progress_spec_helpers'
require OutreachMedia::Engine.root.join('spec','helpers','media_spec_helper.rb').to_s


feature "performance indicators outreach events and media appearances", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include PerformanceIndicatorsSpecHelpers
  include StrategicPlanHelpers
  include SetupHelpers
  include ProgressSpecHelpers
  include MediaSpecHelper

  before do
    setup_strategic_plan
    setup_media_appearances(4)
    setup_projects
    visit strategic_plans_strategic_plan_path(:en, StrategicPlan.most_recent.id)
    open_accordion_for_strategic_priority_one
  end

  scenario "associated projects and media_appearances should be shown" do
    media_text = MediaAppearance.first.title
    project_text = Project.first.title
    expect(page).to have_selector(progress_selector + ".title.media_appearance span", :text => media_text)
    expect(page).to have_selector(progress_selector + ".title.project span", :text => project_text)
  end

  scenario "media appearance progress item should link back to the media appearance" do
    media_text = MediaAppearance.first.title
    click_link(media_text)
    expect(page_heading).to eq "Media Archive"
    expect(number_of_rendered_media_appearances).to eq 1
    expect(number_of_all_media_appearances).to eq 4
    expect(page.find("#media_appearances_controls #title").value).to eq media_text
  end

end
