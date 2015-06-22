require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'


feature "populate strategic plan contents", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit corporate_services_strategic_plan_path(:en, "current")
  end


  scenario "add planned results item" do
    open_accordion_for_strategic_priority_one
    add_planned_result.click
    expect(page).not_to have_selector(add_planned_result_icon)
    fill_in 'planned_result_description', :with => "Achieve nirvana"
    expect{save_planned_result.click; sleep(0.2)}.to change{PlannedResult.count}.from(0).to(1)
    expect(page).to have_selector("table#planned_results tr.planned_result td:first-of-type", :text => "1.1 Achieve nirvana")
  end

  xscenario "try to add multiple planned results without saving" do
    
  end

  xscenario "try to save planned result with blank description field" do
    
  end

  xscenario "delete a planned result item" do
    
  end
end


def open_accordion_for_strategic_priority_one
  page.find("i#toggle").click
end

def save_planned_result
  page.find("i#create_save")
end

def add_planned_result
  page.find(add_planned_result_icon)
end

def add_planned_result_icon
  ".strategic_priority_content table tr:not(.heading) td:first-of-type .new_planned_result"
end
