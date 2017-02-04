require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/setup_helpers'
require_relative '../helpers/planned_result_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/outcomes_spec_helpers'
require_relative '../helpers/activities_spec_helpers'
require_relative '../helpers/strategic_priority_spec_helpers'

feature "when there are no previous strategic plans", :js => true do
  include LoggedInEnAdminUserHelper
  include NavigationHelpers
  include StrategicPlanHelpers

  scenario "navigation menu shows none configured" do
    toggle_navigation_dropdown('Strategic plan')
    expect(page).to have_selector("ul.dropdown-menu>li>a", :text => "none configured")
  end
end

feature "modifying strategic plan configuration", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  xscenario "start date changed with existing strategic plans in the database" do
    
  end
end

feature "select strategic plan from prior years", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPrioritySpecHelpers

  before do
    @sp1 = StrategicPlan.create(:title => "A plan for the millenium")
    StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    @sp2 = StrategicPlan.create(:title => "A plan for the 21st century")
    StrategicPriority.create(:strategic_plan_id => @sp2.id, :priority_level => 1, :description => "We gotta fix this")
  end

  scenario "select the current year and add a strategic priority" do
    visit corporate_services_strategic_plan_path(:en, @sp2.id)
    expect(page).to have_selector(".strategic_priority_title .description .no_edit", :text => "We gotta fix this")
    add_strategic_priority({:priority_level => "Strategic Priority 1", :description => "blah blah blah"})
    expect(page).to have_selector(".strategic_priority_title .description .no_edit", :text => "blah blah blah")
  end

  scenario "add priorities disabled for prior years" do
    visit corporate_services_strategic_plan_path(:en, @sp1.id)
    expect(page).to have_selector(".strategic_priority_title .description .no_edit", :text => "Gonna do things betta")
    if page.driver.browser.is_a? Capybara::Poltergeist::Browser
      expect(add_priority_button['disabled']).to eq "disabled"
    else
      expect(add_priority_button['disabled']).to eq "true"
    end
    add_priority_button.click
    expect(flash_message).to eq "Strategic priorities can only be added to the current strategic plan"
    click_anywhere
    expect(page.find('.message_block .error', :visible=>false)).not_to be_visible
  end
end

feature "restrict user input to a single add or edit", :js => true do
  include LoggedInEnAdminUserHelper
  include SetupHelpers
  include PlannedResultHelpers
  include StrategicPlanHelpers
  include OutcomesSpecHelpers
  include ActivitiesSpecHelpers
  include StrategicPrioritySpecHelpers

  before do
    setup_activity
    visit corporate_services_strategic_plan_path(:en, StrategicPlan.most_recent.id)
    open_accordion_for_strategic_priority_one
  end

  scenario "add planned result terminated by add outcome" do
    add_planned_result.click
    sleep(0.2)
    expect(page).to have_selector(".row.new_planned_result")
    add_outcome.click
    sleep(0.2)
    expect(page).not_to have_selector(".row.new_planned_result")
  end

  scenario "add planned result terminated by edit outcome" do
    add_planned_result.click
    sleep(0.2)
    expect(page).to have_selector(".row.new_planned_result")
    edit_outcome.click
    expect(page).not_to have_selector(".row.new_planned_result")
  end

  scenario "edit planned result terminated by add outcome" do
    edit_planned_result.click
    sleep(0.2)
    expect(page).to have_selector(".planned_result .description .edit.in #planned_result_description")
    add_outcome.click
    expect(page).not_to have_selector(".planned_result .description .edit.in #planned_result_description")
  end

  scenario "edit planned result terminated by edit outcome" do
    edit_planned_result.click
    sleep(0.2)
    edit_outcome.click
    expect(page).not_to have_selector(".planned_result .description .edit.in #planned_result_description")
  end

  xscenario "any add or edit sets the appropriate claim for user_input_request" do
    add_priority_button.click
    expect(user_input_request).to be_claimed_by StrategicPriority
    add_planned_result.click
    expect(user_input_request).to be_claimed_by PlannedResult
    add_outcome.click
    expect(user_input_request).to be_claimed_by Outcome
    add_activity.click
    expect(user_input_request).to be_claimed_by Activity
    edit_strategic_priority.click
    expect(user_input_request).to be_claimed_by StrategicPriority
    edit_planned_result.click
    expect(user_input_request).to be_claimed_by PlannedResult
    edit_outcome.click
    expect(user_input_request).to be_claimed_by Outcome
    edit_activity.click
    expect(user_input_request).to be_claimed_by Activity
  end
end

feature "events after the end date of a strategic plan" do
  include LoggedInEnAdminUserHelper

  xscenario "new strategic plan created with strategic priorities copied" do
    
  end
end

RSpec::Matchers.define :be_claimed_by do |expected|
  match do |actual|
    actual = expected.send(:first).send(:description)
  end
end

def user_input_request
  page.evaluate_script("strategic_plan.get('user_input_requested').get('description')")
end

#def add_priority_button
  #page.find('.add_strategic_priority')
#end

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
