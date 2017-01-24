require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/corporate_services_admin_spec_helpers'
require_relative '../helpers/strategic_plan_helpers'
require 'shared_behaviours/file_admin_behaviour'

feature "strategic plan admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers

  before do
    visit corporate_services_admin_path(:en)
  end

  scenario "add a strategic plan" do
    fill_in("strategic_plan_title", :with => "A plan for the 21st century")
    expect{save_strategic_plan}.to change{StrategicPlan.count}.from(0).to(1)
    expect(StrategicPlan.most_recent.title).to eq "A plan for the 21st century"
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

  before do
    StrategicPlan.create(:title => 'a man a plan')
    visit corporate_services_admin_path(:en)
  end

  scenario "delete a strategic plan" do
    expect{ delete_plan; confirm_deletion; wait_for_ajax }.to change{StrategicPlan.count}.from(1).to(0).
                                                          and change{page.all('tr#strategic_plan').length}.from(1).to(0)
  end

  scenario "add a strategic plan with duplicate title" do
    fill_in("strategic_plan_title", :with => "a man a plan")
    expect{save_strategic_plan}.not_to change{StrategicPlan.count}
    expect(page).to have_selector("#unique_title_error", :text => "title already exists")
  end

end
