require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "strategic plan basic", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  scenario "index page should show the current year" do
    start_date = SiteConfig['corporate_services.strategic_plans.start_date']
    visit corporate_services_strategic_plan_path(:en, "current")
    expect(page).to have_select("strategic_plan_start_date",
                                :selected => "Strategic Plan: Current reporting year #{StrategicPlanStartDate.most_recent.to_s} - #{StrategicPlanStartDate.most_recent.advance(:years => 1, :days => -1).to_s}")
  end
end

feature "modifying strategic plan configuration", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  xscenario "start date changed with existing strategic plans in the database" do
    
  end
end

feature "select strategic plan from prior years", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    sp2 = StrategicPlan.create(:start_date => 18.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp2.id, :priority_level => 1, :description => "We gotta fix this")
  end

  scenario "select a prior year and add a strategic priority" do
    visit corporate_services_strategic_plan_path(:en, "current")
    select("Strategic Plan: Starting #{18.months.ago.to_date.to_s}, ending #{6.months.ago.to_date.advance(:days => -1).to_s}", :from => "strategic_plan_start_date")
    expect(page).to have_selector("[data-editable_attribute='description'] .no_edit", :text => "We gotta fix this")
    add_strategic_priority({:priority_level => "Strategic Priority 1", :description => "blah blah blah"})
    expect(page).to have_selector("[data-editable_attribute='description'] .no_edit", :text => "blah blah blah")
  end

  xscenario "add priorities disabled for prior years" do
    
  end
end

feature "events after the end date of a strategic plan" do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  xscenario "new strategic plan created with strategic priorities copied" do
    
  end
end

def add_priority_button
  page.find('.add_strategic_priority')
end

def add_strategic_priority(attrs)
  add_priority_button.click
  sleep(0.1)
  within "form#new_strategic_priority" do
    select attrs[:priority_level].to_s, :from => 'strategic_priority_priority_level' if attrs[:priority_level]
    fill_in "strategic_priority_description", :with => attrs[:description] if attrs[:description]
    page.find('#edit-save').click
    sleep(0.2)
  end
end
