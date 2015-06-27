require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'


feature "populate strategic plan contents", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    add_planned_result.click
  end


  scenario "add planned results item" do
    expect(page).not_to have_selector("i.new_planned_result")
    fill_in 'planned_result_description', :with => "Achieve nirvana"
    expect{save_planned_result.click; sleep(0.2)}.to change{PlannedResult.count}.from(0).to(1)
    expect(page).to have_selector("table#planned_results tr.planned_result td:first-of-type", :text => "1.1 Achieve nirvana")
  end

  scenario "add multiple planned results" do
    expect(page).not_to have_selector("i.new_planned_result")
    fill_in 'planned_result_description', :with => "Achieve nirvana"
    expect{save_planned_result.click; sleep(0.2)}.to change{PlannedResult.count}.from(0).to(1)
    expect(page).to have_selector("table#planned_results tr.planned_result td:first-of-type", :text => "1.1 Achieve nirvana")
    expect(page).to have_selector(".new_planned_result")
  end

  scenario "try to save planned result with blank description field" do
    expect(page).not_to have_selector("i.new_planned_result")
    expect{save_planned_result.click; sleep(0.2)}.not_to change{PlannedResult.count}
    expect(page).to have_selector("#description_error", :text => "You must enter a description")
  end

end


feature "actions on existing planned results", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "delete a planned result item" do
    page.find("tr.planned_result td.description").hover
    expect{ page.find("tr.planned_result td.description span.delete_icon").click; sleep(0.2)}.to change{PlannedResult.count}.from(1).to(0)
  end

  scenario "edit a planned result item" do
    page.find("tr.planned_result td.description span").click
    fill_in('planned_result_description', :with => "new description")
    expect{ planned_result_save_icon.click; sleep(0.2) }.to change{ PlannedResult.first.description }.to "new description"
    expect(page.find(".planned_result.editable_container .no_edit span:first-of-type").text ).to eq "1.1 new description"
  end
end

def planned_result_save_icon
  page.find('.editable_container i#planned_result_editable1_edit_save')
end

def open_accordion_for_strategic_priority_one
  page.find("i#toggle").click
end

def save_planned_result
  page.find("i#create_save")
end

def add_planned_result
  page.find(".new_planned_result")
end
