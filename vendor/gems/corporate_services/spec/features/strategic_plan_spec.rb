require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "strategic plan", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  scenario "index page should show the current year" do
    start_date = SiteConfig['corporate_services.strategic_plans.start_date']
    visit corporate_services_strategic_plan_path(:en, "current")
    expect(page).to have_select("strategic_plan_start_date",
                                :selected => "Strategic Plan: Current reporting year #{StrategicPlanStartDate.most_recent.to_s} - #{StrategicPlanStartDate.most_recent.advance(:years => 1, :days => -1).to_s}")
  end

  scenario "add strategic priority" do
    visit corporate_services_strategic_plan_path(:en, "current")
    add_strategic_priority({:priority_level => 1, :description => "The application of good governance by public authorities"})
    expect(page).to have_selector('h4.panel-title a', :text => "Strategic Priority 1: The application of good governance by public authorities")
  end

  scenario "filling-in the strategic priority description field" do
    visit corporate_services_strategic_plan_path(:en, "current")
    add_priority_button.click
    sleep(0.1)
    within "form#new_strategic_priority" do
      lorem_96_chars = "Lorem ipsum dolor sit amet salutatus necessitatibus at quo Quot melius philosophia usu eu, iusto"
      fill_in "strategic_priority_description", :with => lorem_96_chars
      description_field =  find("#strategic_priority_description").native
      i = 96
      "smit".each_char do |c|
        description_field.send_keys(c)
        i+=1
        expect(page.find('.chars_remaining').text).to eq "You have #{(100-i).to_s} characters left"
      end
      expect(page.find("#strategic_priority_description").value.length).to eq 100
      description_field.send_keys("m") # 101st char should be rejected
      expect(page.find("#strategic_priority_description").value.length).to eq 100
    end
  end

end

feature "strategic plan with existing strategic priority", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit corporate_services_strategic_plan_path(:en, "current")
  end

  scenario "add second/lower strategic priority" do
    add_strategic_priority({:priority_level => 2, :description => "We gotta improve"})
    expect(page.all('h4.panel-title a').map(&:text).first).to eq "Strategic Priority 1: Gonna do things betta"
    expect(page.all('h4.panel-title a').map(&:text).last).to eq "Strategic Priority 2: We gotta improve"
  end

  scenario "add a second strategic priority that re-orders existing priorities" do
    add_strategic_priority({:priority_level => 1, :description => "We gotta improve"})
    expect(page.all('h4.panel-title a').map(&:text).first).to eq "Strategic Priority 1: We gotta improve"
    expect(page.all('h4.panel-title a').map(&:text).last).to eq "Strategic Priority 2: Gonna do things betta"
  end

  xscenario "edit the description and priority level of an existing strategic priority" do
    
  end

  xscenario "start date changed with existing strategic plans in the database" do
    
  end
end

feature "strategic plan with prior years", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    sp2 = StrategicPlan.create(:start_date => 18.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => sp2.id, :priority_level => 1, :description => "We gotta fix this")
  end

  scenario "select a prior year and add a strategic priority" do
    visit corporate_services_strategic_plan_path(:en, "current")
    select("Strategic Plan: Starting #{18.months.ago.to_date.to_s}, ending #{6.months.ago.to_date.advance(:days => -1).to_s}", :from => "strategic_plan_start_date")
    expect(page).to have_selector('h4.panel-title a', :text => "Strategic Priority 1: We gotta fix this")
    add_strategic_priority({:priority_level => 1, :description => "blah blah blah"})
    expect(page).to have_selector('h4.panel-title a', :text => "blah blah blah")
  end
end

feature "events after the end date of a strategic plan" do
  xscenario "new strategic plan created with strategic priorities copied" do
    
  end
end

def add_priority_button
  page.find('.add_strategic_priority')
end

def add_strategic_priority(attrs)
  add_priority_button.click
  sleep(0.1)
  within "form#new_strategic_priority" do
    select attrs[:priority_level].to_s, :from => 'strategic_priority_priority_level'
    fill_in "strategic_priority_description", :with => attrs[:description]
    click_button "Add"
    sleep(0.2)
  end
end
