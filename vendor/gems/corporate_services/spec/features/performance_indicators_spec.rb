require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/performance_indicators_spec_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/setup_helpers'


feature "populate activity performance indicators", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include PerformanceIndicatorsSpecHelpers
  include StrategicPlanHelpers
  include SetupHelpers

  feature "add performance indicator when there were none before" do
    before do
      sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
      spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
      pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
      o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
      a = Activity.create(:outcome_id => o.id, :description => "50% improvement")
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
      add_performance_indicator.click
    end

    scenario "add single performance indicator item" do
      #expect(page).not_to have_selector("i.new_performance_indicator")
      fill_in 'new_performance_indicator_description', :with => "steam rising"
      fill_in 'new_performance_indicator_target', :with => "88% achievement"
      expect{save_performance_indicator.click; wait_for_ajax}.to change{PerformanceIndicator.count}.from(0).to(1)
      expect(page).to have_selector(performance_indicator_selector + ".description", :text => "1.1.1.1 steam rising")
      expect(page).to have_selector(performance_indicator_selector + ".target", :text => "1.1.1.1 88% achievement")
    end

    scenario "try to save performance indicator with blank description field" do
      #expect(page).not_to have_selector("i.new_performance_indicator")
      expect{save_performance_indicator.click; wait_for_ajax}.not_to change{PerformanceIndicator.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "try to save performance indicator with whitespace description field" do
      #expect(page).not_to have_selector("i.new_performance_indicator")
      fill_in 'new_performance_indicator_description', :with => " "
      expect{save_performance_indicator.click; wait_for_ajax}.not_to change{PerformanceIndicator.count}
      expect(page).to have_selector("#description_error", :text => "You must enter a description")
    end

    scenario "add multiple performance indicator items" do
      #expect(page).not_to have_selector("i.new_performance_indicator")
      fill_in 'new_performance_indicator_description', :with => "steam rising"
      fill_in 'new_performance_indicator_target', :with => "88% achievement"
      expect{save_performance_indicator.click; wait_for_ajax}.to change{PerformanceIndicator.count}.from(0).to(1)
      expect(page).to have_selector(performance_indicator_selector + ".description", :text => "1.1.1.1 steam rising")
      expect(page).to have_selector(performance_indicator_selector + ".target", :text => "1.1.1.1 88% achievement")
      add_performance_indicator.click
      #expect(page).not_to have_selector("i.new_performance_indicator")
      fill_in 'new_performance_indicator_description', :with => "great insight"
      fill_in 'new_performance_indicator_target', :with => "full employment"
      expect{save_performance_indicator.click; wait_for_ajax}.to change{PerformanceIndicator.count}.from(1).to(2)
      expect(page).to have_selector(performance_indicator_selector + ".description", :text => "1.1.1.1.2 great insight")
      expect(page).to have_selector(performance_indicator_selector + ".target", :text => "1.1.1.1.2 full employment")
      expect(page).to have_selector(performance_indicator_selector + ".description", :text => "1.1.1.1.1 steam rising")
      expect(page).to have_selector(performance_indicator_selector + ".target", :text => "1.1.1.1.1 88% achievement")
    end
  end

  feature "add performance indicator to pre-existing" do
    before do
      setup_performance_indicator
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
      add_performance_indicator.click
    end

    scenario "add performance indicators item" do
      #expect(page).not_to have_selector("i.new_performance_indicator")
      fill_in 'new_performance_indicator_description', :with => "great insight"
      fill_in 'new_performance_indicator_target', :with => "full employment"
      expect{save_performance_indicator.click; wait_for_ajax}.to change{PerformanceIndicator.count}.from(1).to(2)
      expect(page).to have_selector(performance_indicator_selector + ".description", :text => "1.1.1.1.2 great insight")
      expect(page).to have_selector(performance_indicator_selector + ".target", :text => "1.1.1.1.2 full employment")
    end

    scenario "add performance indicators item but cancel addition" do
      cancel_performance_indicator_addition
      expect(page).not_to have_selector('div.new_performance_indicator')
    end
  end
end


feature "actions on existing performance indicators", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include PerformanceIndicatorsSpecHelpers
  include StrategicPlanHelpers
  include SetupHelpers

  before do
    activity = setup_activity
    resize_browser_window
    PerformanceIndicator.create(:activity_id => activity.id, :description => "great effort", :target => "15% improvement")
    PerformanceIndicator.create(:activity_id => activity.id, :description => "things get better", :target => "85% improvement")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  scenario "delete the first of multiple performance indicators" do
    page.all(performance_indicator_selector + ".description")[0].hover
    expect{ click_delete_icon; confirm_deletion; wait_for_ajax}.to change{PerformanceIndicator.count}.from(2).to(1)
    expect(page.find(performance_indicator_selector + ".description").text).to eq "1.1.1.1.1 things get better"
    expect(page.find(performance_indicator_selector + ".target").text).to eq "1.1.1.1.1 85% improvement"
  end

  scenario "delete one of multiple performance indicators, not the first" do
    page.all(performance_indicator_selector + ".description")[1].hover
    expect{ click_delete_icon; confirm_deletion; wait_for_ajax}.to change{PerformanceIndicator.count}.from(2).to(1)
    expect(page.find(performance_indicator_selector + ".description").text).to eq "1.1.1.1.1 great effort"
    expect(page.find(performance_indicator_selector + ".target").text).to eq "1.1.1.1.1 15% improvement"
  end

  scenario "edit the first of multiple performance indicators" do
    page.all(performance_indicator_selector + ".description div.no_edit span:nth-of-type(1)")[0].click
    performance_indicator_description_field.first.set("new description")
    performance_indicator_target_field.first.set("total satisfaction")
    expect{ performance_indicator_save_icon.click; wait_for_ajax }.to change{ PerformanceIndicator.first.description }.to "new description"
    expect(page.all(performance_indicator_selector+".description .no_edit span:first-of-type")[0].text ).to eq "1.1.1.1.1 new description"
    expect(page.all(performance_indicator_selector+".target .no_edit span:first-of-type")[0].text ).to eq "1.1.1.1.1 total satisfaction"
  end

  scenario "edit to blank description and cancel" do
    first_performance_indicator_description.click
    performance_indicator_edit_cancel.click
    expect(first_performance_indicator_description.text).to eq "1.1.1.1.1 great effort"
  end

  scenario "edit to blank description and cancel" do
    first_performance_indicator_description.click
    performance_indicator_description_field.first.set("")
    expect{ performance_indicator_save_icon.click; wait_for_ajax }.not_to change{ PerformanceIndicator.first.description }
    expect(page).to have_selector(".performance_indicator .description #description_error", :text => "You must enter a description")
    performance_indicator_edit_cancel.click
    # error msg disappears on cancel
    expect(page).not_to have_selector(".performance_indicator .description #description_error", :text => "You must enter a description")
    first_performance_indicator_description.click
    # error message doesn't reappear on re-edit
    expect(page).not_to have_selector(".performance_indicator .description #description_error", :text => "You must enter a description")
    # original value should be in the text area input field
    expect(performance_indicator_description_field.first.value).to eq "great effort"
  end

  scenario "edit one of multiple performance indicators, not the first" do
    page.all(performance_indicator_selector + ".description div.no_edit span:nth-of-type(1)")[1].click
    performance_indicator_description_field.last.set("new description")
    performance_indicator_target_field.last.set("total satisfaction")
    performance_indicator_save_icon.click
    wait_for_ajax
    expect(page.all(performance_indicator_selector+".description .no_edit span:first-of-type")[1].text ).to eq "1.1.1.1.2 new description"
    expect(page.all(performance_indicator_selector+".target .no_edit span:first-of-type")[1].text ).to eq "1.1.1.1.2 total satisfaction"
    expect( PerformanceIndicator.last.description ).to eq "new description"
  end
end
