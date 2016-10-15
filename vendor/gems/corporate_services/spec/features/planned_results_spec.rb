require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/planned_result_helpers'

feature "show existing planned result", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include PlannedResultHelpers

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
    sleep(0.2)
    expect(page.all(".table#planned_results .row.planned_result .row.outcome .col-md-2.description")[0].text).to eq "1.1.1 smarter thinking"
    expect(page.all(".table#planned_results .row.planned_result .row.outcome .col-md-2.description")[1].text).to eq "1.1.2 pervasive niftiness"
  end
end

feature "populate strategic plan contents", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include PlannedResultHelpers

  before do
    sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit corporate_services_strategic_plan_path(:en, "current")
    page.execute_script("$('.fade').removeClass('fade')")
    open_accordion_for_strategic_priority_one
    add_planned_result.click
  end

  scenario "add planned results item" do
    expect(page).not_to have_selector("i.new_planned_result")
    fill_in 'planned_result_description', :with => "Achieve nirvana"
    expect{save_planned_result.click; wait_for_ajax}.to change{PlannedResult.count}.from(0).to(1)
    expect(page).to have_selector(".table#planned_results .row.planned_result .col-md-2.description", :text => "1.1 Achieve nirvana")
  end

  scenario "add multiple planned results" do
    expect(page).not_to have_selector("i.new_planned_result")
    fill_in 'planned_result_description', :with => "Achieve nirvana"
    save_planned_result.click
    wait_for_ajax
    expect(PlannedResult.count).to eq 1
    expect(page).to have_selector(".table#planned_results .row.planned_result .col-md-2:first-of-type", :text => "1.1 Achieve nirvana")
    expect(page).to have_selector(".new_planned_result")
  end

  scenario "try to save planned result with blank description field" do
    expect(page).not_to have_selector("i.new_planned_result")
    expect{save_planned_result.click; wait_for_ajax}.not_to change{PlannedResult.count}
    expect(page).to have_selector("#description_error", :text => "You must enter a description")
  end

  scenario "try to save planned result with whitespace-only description field" do
    expect(page).not_to have_selector("i.new_planned_result")
    fill_in 'planned_result_description', :with => " "
    save_planned_result.click
    expect(page).to have_selector("#description_error", :text => "You must enter a description", :visible => true)
    #expect{save_planned_result.click}.
      #to change{page.all("#description_error", :text => "You must enter a description", :visible => true).count }.from(0).to(1).
      #and change{PlannedResult.count}.by(0)
  end

end


feature "actions on existing planned results", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include PlannedResultHelpers

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something not so profound")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "delete a planned result item" do
    expect(page.all('.row.planned_result .col-md-2.description .no_edit span:first-of-type')[0].text).to eq "1.1 Something profound"
    expect(page.all('.row.planned_result .col-md-2.description .no_edit span:first-of-type')[1].text).to eq "1.2 Something not so profound"
    page.all(".row.planned_result .col-md-2.description")[0].hover
    expect{ click_delete_planned_result; confirm_deletion; wait_for_ajax}.to change{ PlannedResult.count }.to(1)
    expect(page.find('.row.planned_result .col-md-2.description .no_edit span:first-of-type').text).to eq "1.1 Something not so profound"
  end

  scenario "edit a planned result item" do
    page.all(".row.planned_result .col-md-2.description span")[0].click
    fill_in('planned_result_description', :with => "new description")
    expect{ planned_result_save_icon.click; wait_for_ajax }.to change{ PlannedResult.first.description }.to("new description")
    expect(page.all(".planned_result.editable_container .col-md-2.description .no_edit span:first-of-type")[0].text ).to eq "1.1 new description"
  end

  scenario "edit without making changes and cancel" do
    planned_results_descriptions[0].click
    cancel_edit_planned_result.click
    expect(page.all(".planned_result.editable_container .col-md-2.description .no_edit span:first-of-type")[0].text ).to eq "1.1 Something profound"
    planned_results_descriptions[0].click
    expect(page.find('#planned_result_description').value).to eq "Something profound"
  end

  scenario "edit to blank description" do
    planned_results_descriptions[0].click
    fill_in('planned_result_description', :with => "")
    expect{ planned_result_save_icon.click; wait_for_ajax }.not_to change{ PlannedResult.first.description }
    expect(page).to have_selector(".planned_result #description_error", :text => "You must enter a description")
    cancel_edit_planned_result.click
    expect(page).not_to have_selector(".planned_result #description_error", :text => "You must enter a description")
    expect(page).to have_selector(".table#planned_results .row.planned_result .col-md-2.description", :text => "1.1 Something profound")
  end
end
