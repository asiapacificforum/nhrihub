require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "show existing planned result", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => sp1.id, :description => "Something profound")
    Outcome.create(:description => "smarter thinking", :planned_result_id => pr.id)
    Outcome.create(:description => "pervasive niftiness", :planned_result_id => pr.id)
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  it "should render the first outcome inline and the second outcome after the planned result" do
    expect(page).to have_selector(".table#planned_results .row.planned_result .col-md-2:nth-of-type(2)", :text => "1.1.1 smarter thinking")
    expect(page).to have_selector(".table#planned_results .row.outcome .col-md-2.description", :text => "1.1.2 pervasive niftiness")
  end
end

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
    fill_in "planned_result_outcomes__description", :with => "Total enlightenment"
    expect{save_planned_result.click; sleep(0.2)}.to change{PlannedResult.count}.from(0).to(1).
                                                       and change{Outcome.count}.from(0).to(1)
    expect(page).to have_selector(".table#planned_results .row.planned_result .col-md-2.description", :text => "1.1 Achieve nirvana")
    expect(page).to have_selector(".table#planned_results .row.planned_result .col-md-2.outcome", :text => "1.1.1 Total enlightenment")
  end

  scenario "add multiple planned results" do
    expect(page).not_to have_selector("i.new_planned_result")
    fill_in 'planned_result_description', :with => "Achieve nirvana"
    expect{save_planned_result.click; sleep(0.2)}.to change{PlannedResult.count}.from(0).to(1)
    expect(page).to have_selector(".table#planned_results .row.planned_result .col-md-2:first-of-type", :text => "1.1 Achieve nirvana")
    expect(page).to have_selector(".new_planned_result")
  end

  scenario "try to save planned result with blank description field" do
    expect(page).not_to have_selector("i.new_planned_result")
    expect{save_planned_result.click; sleep(0.2)}.not_to change{PlannedResult.count}
    expect(page).to have_selector("#description_error", :text => "You must enter a description")
  end

  scenario "try to save planned result with whitespace-only description field" do
    expect(page).not_to have_selector("i.new_planned_result")
    fill_in 'planned_result_description', :with => " "
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
    page.find(".row.planned_result .col-md-2.description").hover
    expect{ page.find(".row.planned_result .col-md-2.description span.delete_icon").click; sleep(0.2)}.to change{PlannedResult.count}.from(1).to(0)
  end

  scenario "edit a planned result item" do
    page.find(".row.planned_result .col-md-2.description span").click
    fill_in('planned_result_description', :with => "new description")
    fill_in "planned_result_outcomes__description", :with => "Total enlightenment"
    expect{ planned_result_save_icon.click; sleep(0.2) }.to change{ PlannedResult.first.description }.to("new description")
    expect( Outcome.first.description ).to eq "Total enlightenment"
    expect(page.find(".planned_result.editable_container .col-md-2.description .no_edit span:first-of-type").text ).to eq "1.1 new description"
    expect(page.find(".planned_result.editable_container .col-md-2.outcome .no_edit span:first-of-type").text ).to eq "1.1.1 Total enlightenment"
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
