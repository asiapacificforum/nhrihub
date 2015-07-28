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
      #expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "think really hard"
      fill_in 'new_activity_performance_indicator', :with => "steam rising"
      expect{save_activity.click; sleep(0.2)}.to change{Activity.count}.from(0).to(1)
      expect(page).to have_selector(activity_selector + ".description", :text => "1.1.1.1 think really hard")
      expect(page).to have_selector(activity_selector + ".performance_indicator", :text => "1.1.1.1 steam rising")
    end

    scenario "try to save activity with blank description field" do
      #expect(page).not_to have_selector("i.new_activity")
      expect{save_activity.click; sleep(0.2)}.not_to change{Activity.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "try to save activity with whitespace description field" do
      #expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => " "
      expect{save_activity.click; sleep(0.2)}.not_to change{Activity.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "add multiple activity items" do
      #expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "think really hard"
      fill_in 'new_activity_performance_indicator', :with => "steam rising"
      expect{save_activity.click; sleep(0.2)}.to change{Activity.count}.from(0).to(1)
      expect(page).to have_selector(activity_selector + ".description", :text => "1.1.1.1 think really hard")
      expect(page).to have_selector(activity_selector + ".performance_indicator", :text => "1.1.1.1 steam rising")
      add_activity.click
      #expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "ruminate mightily"
      fill_in 'new_activity_performance_indicator', :with => "great insight"
      expect{save_activity.click; sleep(0.2)}.to change{Activity.count}.from(1).to(2)
      expect(page).to have_selector(activity_selector + ".description", :text => "1.1.1.2 ruminate mightily")
      expect(page).to have_selector(activity_selector + ".performance_indicator", :text => "1.1.1.2 great insight")
    end
  end

  feature "add activity to pre-existing" do
    before do
      sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
      spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
      pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
      o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
      o.activities << Activity.new(:description => "Smarter thinking")
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
      add_activity.click
    end


    scenario "add activities item" do
      #expect(page).not_to have_selector("i.new_activity")
      fill_in 'new_activity_description', :with => "work really hard"
      fill_in 'new_activity_performance_indicator', :with => "great insight"
      expect{save_activity.click; sleep(0.2)}.to change{Activity.count}.from(1).to(2)
      expect(page).to have_selector(activity_selector + ".description", :text => "1.1.1.2 work really hard")
      expect(page).to have_selector(activity_selector + ".performance_indicator", :text => "1.1.1.2 great insight")
    end
  end


end


feature "actions on existing activities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "whirled peas")
    Activity.create(:outcome_id => o.id, :description => "work hard", :performance_indicator => "great effort")
    Activity.create(:outcome_id => o.id, :description => "do the right thing", :performance_indicator => "things get better")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "delete the first of multiple activities" do
    page.all(activity_selector + ".description")[0].hover
    expect{ page.find(activity_selector + "span.delete_icon").click; sleep(0.2)}.to change{Activity.count}.from(2).to(1)
    expect(page.find(activity_selector + ".description").text).to eq "1.1.1.1 do the right thing"
    expect(page.find(activity_selector + ".performance_indicator").text).to eq "1.1.1.1 things get better"
  end

  scenario "delete one of multiple activities, not the first" do
    page.all(activity_selector + ".description")[1].hover
    expect{ page.find(activity_selector + "span.delete_icon").click; sleep(0.2)}.to change{Activity.count}.from(2).to(1)
    expect(page.find(activity_selector + ".description").text).to eq "1.1.1.1 work hard"
    expect(page.find(activity_selector + ".performance_indicator").text).to eq "1.1.1.1 great effort"
  end

  scenario "edit the first of multiple activities" do
    page.all(activity_selector + ".description div.no_edit span:nth-of-type(1)")[0].click
    activity_description_field.first.set("new description")
    activity_performance_indicator_field.first.set("new performance indicator")
    expect{ activity_save_icon.click; sleep(0.2) }.to change{ Activity.first.description }.to "new description"
    expect(page.all(activity_selector+".description .no_edit span:first-of-type")[0].text ).to eq "1.1.1.1 new description"
    expect(page.all(activity_selector+".performance_indicator .no_edit span:first-of-type")[0].text ).to eq "1.1.1.1 new performance indicator"
  end

  scenario "edit one of multiple activities, not the first" do
    page.all(activity_selector + ".description div.no_edit span:nth-of-type(1)")[1].click
    activity_description_field.last.set("new description")
    activity_performance_indicator_field.first.set("new performance indicator")
    expect{ activity_save_icon.click; sleep(0.2) }.to change{ Activity.last.description }.to "new description"
    expect(page.all(activity_selector+".description .no_edit span:first-of-type")[1].text ).to eq "1.1.1.2 new description"
    expect(page.all(activity_selector+".performance_indicator .no_edit span:first-of-type")[1].text ).to eq "1.1.1.2 new performance indicator"
  end
end

def activity_selector
  ".table#planned_results .row.planned_result .row.outcome .row.activity "
end

def activity_description_field
  page.all(activity_selector + ".description textarea").select{|i| i['id'] && i['id'].match(/activity_\d_description/)}
end

def activity_performance_indicator_field
  page.all(activity_selector + ".performance_indicator textarea").select{|i| i['id'] && i['id'].match(/activity_\d_performance_indicator/)}
end

def activity_save_icon
  page.all(activity_selector + ".description .edit.in i.fa-check").detect{|i| i['id'] && i['id'].match(/activity_editable\d+_edit_save/)}
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
