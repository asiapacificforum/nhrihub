require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'


feature "populate plannned result outcomes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  feature "add outcome when there were none before" do
    before do
      sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
      spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
      pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
      add_outcome.click
    end

    scenario "add single outcome item" do
      expect(page).not_to have_selector("i.new_outcome")
      fill_in 'new_outcome_description', :with => "Achieve nirvana"
      expect{save_outcome.click; sleep(0.2)}.to change{Outcome.count}.from(0).to(1)
      expect(page).to have_selector("table#planned_results tr.planned_result td:nth-of-type(2)", :text => "1.1.1 Achieve nirvana")
    end

    scenario "try to save outcome with blank description field" do
      expect(page).not_to have_selector("i.new_outcome")
      expect{save_outcome.click; sleep(0.2)}.not_to change{Outcome.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "try to save outcome with whitespace description field" do
      expect(page).not_to have_selector("i.new_outcome")
      fill_in 'new_outcome_description', :with => " "
      expect{save_outcome.click; sleep(0.2)}.not_to change{Outcome.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "add multiple outcome items" do
      expect(page).not_to have_selector("i.new_outcome")
      fill_in 'new_outcome_description', :with => "Achieve nirvana"
      expect{save_outcome.click; sleep(0.2)}.to change{Outcome.count}.from(0).to(1)
      expect(page).to have_selector("table#planned_results tr.planned_result td:nth-of-type(2)", :text => "1.1.1 Achieve nirvana")
      add_outcome.click
      expect(page).not_to have_selector("i.new_outcome")
      fill_in 'new_outcome_description', :with => "Total enlightenment"
      expect{save_outcome.click; sleep(0.2)}.to change{Outcome.count}.from(1).to(2)
      expect(page).to have_selector("table#planned_results tr.outcome td:nth-of-type(2)", :text => "1.1.2 Total enlightenment")
    end
  end

  feature "add outcome to pre-existing" do
    before do
      sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
      spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
      pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
      pr.outcomes << Outcome.new(:description => "Smarter thinking")
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
      add_outcome.click
    end


    scenario "add outcomes item" do
      expect(page).not_to have_selector("i.new_outcome")
      fill_in 'new_outcome_description', :with => "Achieve nirvana"
      expect{save_outcome.click; sleep(0.2)}.to change{Outcome.count}.from(1).to(2)
      expect(page).to have_selector("table#planned_results tr.outcome td:nth-of-type(2)", :text => "1.1.2 Achieve nirvana")
    end
  end


end


feature "actions on existing outcomes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o1 = Outcome.create(:planned_result_id => pr.id, :description => "whirled peas")
    o2 = Outcome.create(:planned_result_id => pr.id, :description => "cosmic harmony")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "delete the first of multiple outcomes" do
    page.find("tr.planned_result td.outcome").hover
    expect{ page.find("tr.planned_result td.outcome span.delete_icon").click; sleep(0.2)}.to change{Outcome.count}.from(2).to(1)
    expect(page.find("tr.planned_result td.outcome").text).to eq "1.1.1 cosmic harmony"
  end

  scenario "delete one of multiple outcomes, not the first" do
    page.find("tr.outcome td.description").hover
    expect{ page.find("tr.outcome td.description span.delete_icon").click; sleep(0.2)}.to change{Outcome.count}.from(2).to(1)
    expect(page.find("tr.planned_result td.outcome").text).to eq "1.1.1 whirled peas"
    expect(page).not_to have_selector "tr.outcome"
  end

  scenario "edit the first of multiple outcomes" do
    page.find("tr.planned_result td.outcome span").click
    planned_result_outcome_description_field.set("new description")
    expect{ planned_result_save_icon.click; sleep(0.2) }.to change{ Outcome.first.description }.to "new description"
    expect(page.find(".planned_result.editable_container .outcome .no_edit span:first-of-type").text ).to eq "1.1.1 new description"
  end

  scenario "edit one of multiple outcomes, not the first" do
    page.find("tr.outcome td.description span").click
    outcome_description_field.set("new description")
    expect{ outcome_save_icon.click; sleep(0.2) }.to change{ Outcome.last.description }.to "new description"
    expect(page.find(".outcome.editable_container .description .no_edit span:first-of-type").text ).to eq "1.1.2 new description"
  end
end

def outcome_description_field
  page.all("tr.outcome textarea").detect{|el| el['id'].match(/outcome_\d*_description/)}
end

def planned_result_outcome_description_field
  page.all("tr.planned_result textarea").detect{|el| el['id'].match(/planned_result_outcomes_\d*_description/)}
end

def outcome_save_icon
  page.all('.outcome.editable_container i').detect{|i| i['id'] && i['id'].match(/outcome_editable\d+_edit_save/)}
end

def planned_result_save_icon
  page.all('.planned_result.editable_container i').detect{|i| i['id'].match(/planned_result_editable\d*_edit_save/)}
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
