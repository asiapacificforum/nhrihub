require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'


feature "populate plannned result activities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  feature "add activity when there were none before" do
    before do
      sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
      spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
      pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
      o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
      add_activity.click
    end

    scenario "add single activity item" do
      expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "think really hard"
      expect{save_activity.click; sleep(0.2)}.to change{activity.count}.from(0).to(1)
      expect(page).to have_selector("table#planned_results tr.planned_result td:nth-of-type(3)", :text => "1.1.1.1 think really hard")
    end

    scenario "try to save activity with blank description field" do
      expect(page).not_to have_selector("i.new_activity")
      expect{save_activity.click; sleep(0.2)}.not_to change{activity.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "try to save activity with whitespace description field" do
      expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => " "
      expect{save_activity.click; sleep(0.2)}.not_to change{activity.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "add multiple activity items" do
      expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "Achieve nirvana"
      expect{save_activity.click; sleep(0.2)}.to change{activity.count}.from(0).to(1)
      expect(page).to have_selector("table#planned_results tr.planned_result td:nth-of-type(2)", :text => "1.1.1 Achieve nirvana")
      add_activity.click
      expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "Total enlightenment"
      expect{save_activity.click; sleep(0.2)}.to change{activity.count}.from(1).to(2)
      expect(page).to have_selector("table#planned_results tr.activity td:nth-of-type(2)", :text => "1.1.2 Total enlightenment")
    end
  end

  feature "add activity to pre-existing" do
    before do
      sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
      spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
      pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
      pr.activities << activity.new(:description => "Smarter thinking")
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
      add_activity.click
    end


    scenario "add activities item" do
      expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "Achieve nirvana"
      expect{save_activity.click; sleep(0.2)}.to change{activity.count}.from(1).to(2)
      expect(page).to have_selector("table#planned_results tr.activity td:nth-of-type(2)", :text => "1.1.2 Achieve nirvana")
    end
  end


end


feature "actions on existing activities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o1 = activity.create(:planned_result_id => pr.id, :description => "whirled peas")
    o2 = activity.create(:planned_result_id => pr.id, :description => "cosmic harmony")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "delete the first of multiple activities" do
    page.find("tr.planned_result td.activity div").hover
    expect{ page.find("tr.planned_result td.activity span.delete_icon").click; sleep(0.2)}.to change{activity.count}.from(2).to(1)
    expect(page.find("tr.planned_result td.activity").text).to eq "1.1.1 cosmic harmony"
  end

  scenario "delete one of multiple activities, not the first" do
    page.find("tr.activity td.description div").hover
    expect{ page.find("tr.activity td.description span.delete_icon").click; sleep(0.2)}.to change{activity.count}.from(2).to(1)
    expect(page.find("tr.planned_result td.activity").text).to eq "1.1.1 whirled peas"
    expect(page).not_to have_selector "tr.activity"
  end

  scenario "edit the first of multiple activities" do
    page.find("tr.planned_result td.activity span").click
    planned_result_activity_description_field.set("new description")
    expect{ planned_result_save_icon.click; sleep(0.2) }.to change{ activity.first.description }.to "new description"
    expect(page.find(".planned_result.editable_container .activity .no_edit span:first-of-type").text ).to eq "1.1.1 new description"
  end

  scenario "edit one of multiple activities, not the first" do
    page.find("tr.activity td.description span").click
    activity_description_field.set("new description")
    expect{ activity_save_icon.click; sleep(0.2) }.to change{ activity.last.description }.to "new description"
    expect(page.find(".activity.editable_container .description .no_edit span:first-of-type").text ).to eq "1.1.2 new description"
  end
end

def activity_description_field
  page.all("tr.activity textarea").detect{|el| el['id'].match(/activity_\d*_description/)}
end

def planned_result_activity_description_field
  page.all("tr.planned_result textarea").detect{|el| el['id'].match(/planned_result_activities_\d*_description/)}
end

def activity_save_icon
  page.all('.activity.editable_container i').detect{|i| i['id'] && i['id'].match(/activity_editable\d+_edit_save/)}
end

def planned_result_save_icon
  page.all('.planned_result.editable_container i').detect{|i| i['id'].match(/planned_result_editable\d*_edit_save/)}
end

def open_accordion_for_strategic_priority_one
  page.find("i#toggle").click
end

def save_activity
  page.find("i#create_save")
end

def add_activity
  page.find(".new_activity")
end
