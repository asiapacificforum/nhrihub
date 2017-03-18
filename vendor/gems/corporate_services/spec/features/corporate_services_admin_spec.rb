require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/corporate_services_admin_spec_helpers'
require_relative '../helpers/strategic_plan_helpers'
require 'shared_behaviours/file_admin_behaviour'

feature "strategic plan admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include CorporateServicesAdminSpecHelpers

  before do
    visit corporate_services_admin_path(:en)
  end

  scenario "add a strategic plan" do
    fill_in("strategic_plan_title", :with => "A plan for the 21st century")
    expect{save_strategic_plan}.to change{StrategicPlan.count}.from(0).to(1)
    expect(StrategicPlan.most_recent.title).to eq "A plan for the 21st century"
    expect(StrategicPlan.most_recent.strategic_priorities.length ).to eq(0)
    expect(strategic_plan_menu).to include "A plan for the 21st century (current)"
    expect(strategic_plan_menu).not_to include "none configured"
    expect(strategic_plan_list).to include "A plan for the 21st century (current)"
  end

  scenario "add a strategic plan with blank title" do
    fill_in("strategic_plan_title", :with => "")
    expect{save_strategic_plan}.not_to change{StrategicPlan.count}
    expect(page).to have_selector("#title_error", :text => "title cannot be blank")
  end

  scenario "add a strategic plan with whitespace title" do
    fill_in("strategic_plan_title", :with => "  ")
    expect{save_strategic_plan}.not_to change{StrategicPlan.count}
    expect(page).to have_selector("#title_error", :text => "title cannot be blank")
  end
end

feature "when there are already some strategic plans", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include CorporateServicesAdminSpecHelpers

  before do
    FactoryGirl.create(:strategic_plan, :title => 'the plan for the planet')
    # it's well-populated so that we can test copy of associations
    FactoryGirl.create(:strategic_plan, :well_populated, :title => 'a man a plan')
    visit corporate_services_admin_path(:en)
  end

  scenario "delete a strategic plan" do
    expect(strategic_plan_menu).to include "a man a plan (current)"
    expect(strategic_plan_list).to include "a man a plan (current)"
    expect(strategic_plan_menu).to include "the plan for the planet"
    expect(strategic_plan_list).to include "the plan for the planet"
    expect{ delete_plan; confirm_deletion; wait_for_ajax }.to change{StrategicPlan.count}.from(2).to(1).
                                                          and change{strategic_plan_list.length}.from(2).to(1)
    expect(strategic_plan_menu).to include "a man a plan (current)"
    expect(strategic_plan_list).to include "a man a plan (current)"
    expect(strategic_plan_menu).not_to include "the plan for the planet"
    expect(strategic_plan_list).not_to include "the plan for the planet"
    sleep(0.2)
    expect{ delete_plan; confirm_deletion; wait_for_ajax }.to change{StrategicPlan.count}.from(1).to(0)
    expect(strategic_plan_menu).not_to include "a man a plan (current)"
    expect(strategic_plan_list).not_to include "a man a plan (current)"
    expect(strategic_plan_menu).not_to include "the plan for the planet"
    expect(strategic_plan_list).not_to include "the plan for the planet"
    expect(strategic_plan_menu).to include "none configured"
    expect(strategic_plan_list).to include "none configured"
  end

  scenario "delete the current strategic plan" do
    expect(strategic_plan_menu).to include "the plan for the planet"
    expect(strategic_plan_menu).to include "a man a plan (current)"
    expect{ delete_current_plan; confirm_deletion; wait_for_ajax }.to change{StrategicPlan.count}.from(2).to(1).
                                                          and change{strategic_plan_list.length}.from(2).to(1)
    expect(strategic_plan_menu).to include "the plan for the planet (current)"
    expect(strategic_plan_list).to include "the plan for the planet (current)"
  end

  scenario "delete and then re-add a strategic plan" do
    delete_plan
    confirm_deletion
    wait_for_ajax
    fill_in("strategic_plan_title", :with => "the plan for the planet")
    expect{save_strategic_plan}.to change{StrategicPlan.count}.from(1).to(2)
  end

  scenario "add a duplicate and delete the original" do
    fill_in("strategic_plan_title", :with => "the plan for the planet")
    save_strategic_plan
    expect(page).to have_selector("#unique_title_error", :text => "title already exists")
    delete_plan
    confirm_deletion
    wait_for_ajax
    save_strategic_plan
    expect(page).not_to have_selector("#unique_title_error", :text => "title already exists")
  end

  scenario "add a strategic plan with duplicate title" do
    fill_in("strategic_plan_title", :with => "a man a plan")
    expect{save_strategic_plan}.not_to change{StrategicPlan.count}
    expect(page).to have_selector("#unique_title_error", :text => "title already exists")
  end

  scenario "add a strategic plan with copy flag checked" do
    expect(strategic_plan_menu).to include "a man a plan (current)"
    fill_in("strategic_plan_title", :with => "a man a better plan")
    check("copy")
    expect{save_strategic_plan}.to change{StrategicPlan.count}.from(2).to(3)
    expect(StrategicPlan.most_recent.strategic_priorities.length).to eq 2
    expect(strategic_plan_menu).to include "a man a better plan (current)"
    expect(strategic_plan_menu).to include "a man a plan"
  end

end
