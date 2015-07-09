require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'


feature "populate strategic plan contents", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    add_outcome.click
  end


  scenario "add outcomes item" do
    expect(page).not_to have_selector("i.new_outcome")
    fill_in 'outcome_description', :with => "Achieve nirvana"
    expect{save_outcome.click; sleep(0.2)}.to change{Outcome.count}.from(0).to(1)
    expect(page).to have_selector("table#outcomes tr.outcome td:first-of-type", :text => "1.1 Achieve nirvana")
  end

  xscenario "add multiple outcomes" do
    expect(page).not_to have_selector("i.new_outcome")
    fill_in 'outcome_description', :with => "Achieve nirvana"
    expect{save_outcome.click; sleep(0.2)}.to change{Outcome.count}.from(0).to(1)
    expect(page).to have_selector("table#outcomes tr.outcome td:first-of-type", :text => "1.1 Achieve nirvana")
    expect(page).to have_selector(".new_outcome")
  end

  xscenario "try to save outcome with blank description field" do
    expect(page).not_to have_selector("i.new_outcome")
    expect{save_outcome.click; sleep(0.2)}.not_to change{Outcome.count}
    expect(page).to have_selector("#description_error", :text => "You must enter a description")
  end

end


feature "actions on existing outcomes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    Outcome.create(:strategic_priority_id => spl.id, :description => "Something profound")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  xscenario "delete a outcome item" do
    page.find("tr.outcome td.description").hover
    expect{ page.find("tr.outcome td.description span.delete_icon").click; sleep(0.2)}.to change{Outcome.count}.from(1).to(0)
  end

  xscenario "edit a outcome item" do
    page.find("tr.outcome td.description span").click
    fill_in('outcome_description', :with => "new description")
    expect{ outcome_save_icon.click; sleep(0.2) }.to change{ Outcome.first.description }.to "new description"
    expect(page.find(".outcome.editable_container .no_edit span:first-of-type").text ).to eq "1.1 new description"
  end
end

def outcome_save_icon
  page.find('.editable_container i#outcome_editable1_edit_save')
end

def open_accordion_for_strategic_priority_one
  page.find("i#toggle").click
end

def save_outcome
  page.find("i#create_save")
end

def add_outcome
  page.find(".new_outcome")
end
