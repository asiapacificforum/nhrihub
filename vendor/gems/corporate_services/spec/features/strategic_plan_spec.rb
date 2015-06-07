require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "strategic plan", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  scenario "index page should show the current year" do
    start_date = SiteConfig['corporate_services.strategic_plans.start_date']
    visit corporate_services_strategic_plan_path(:en, "current")
    expect(page).to have_select("strategic_plan_start_date",
                                :selected => "Current reporting year #{StrategicPlanStartDate.most_recent} - #{StrategicPlanStartDate.most_recent.advance(:years => 1, :days => -1)}")
  end

  xscenario "select a prior year" do
    
  end

  scenario "add strategic priority" do
    visit corporate_services_strategic_plan_path(:en, "current")
    add_priority_button.click
    sleep(0.1)
    within "form#new_strategic_priority" do
      select "1", :from => 'strategic_priority_priority_level'
      fill_in "strategic_priority_description", :with => "The application of good governance by public authorities"
      click_button "Add"
      sleep(0.2)
    end
    expect(page).to have_selector('.strategic_priority td', :text => "Strategic Priority 1: The application of good governance by public authorities")
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

  xscenario "add second/lower strategic priority" do
    
  end

  xscenario "add a second strategic priority that re-orders existing priorities" do
    
  end
end

def add_priority_button
  page.find('.add_strategic_priority')
end
