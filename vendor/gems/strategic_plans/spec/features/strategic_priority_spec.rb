require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/strategic_priority_spec_helpers'

feature "adding strategic priorities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPrioritySpecHelpers

  before do
    StrategicPlan.create(:title => "stuff and stuff")
    visit strategic_plans_strategic_plan_path(:en, StrategicPlan.most_recent.id)
  end

  scenario "add strategic priority" do
    add_strategic_priority({:priority_level => "Strategic Priority 1", :description => "The application of good governance by public authorities"})
    expect(page).to have_selector(".strategic_priority_title .description .no_edit span", :text => "The application of good governance by public authorities")
  end

  scenario "filling-in the strategic priority description field" do
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

  scenario "submit with errors: no priority selected" do
    expect{ add_strategic_priority({:description => "blinka blonka bloo"}) }.not_to change{ StrategicPriority.count }
    expect(page).to have_selector('.new_strategic_priority #priority_level_error', :text => "You must select the priority level")
  end

  scenario "submit with errors: no description entered" do
    expect{ add_strategic_priority({:priority_level => "Strategic Priority 1"}) }.not_to change{ StrategicPriority.count }
    expect(page).to have_selector('.new_strategic_priority #description_error', :text => "You must enter a description")
  end

  scenario "submit with errors: whitespace only description" do
    expect{ add_strategic_priority({:priority_level => "Strategic Priority 1", :description => " "}) }.not_to change{ StrategicPriority.count }
    expect(page).to have_selector('.new_strategic_priority #description_error', :text => "You must enter a description")
  end

  scenario "click 'Add strategic priority' more than once without submitting" do
    add_priority_button.click
    add_priority_button.click
    expect(page).to have_selector('form#new_strategic_priority', :count => 1)
  end
end

feature "strategic plan multiple strategic priorities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPrioritySpecHelpers
  before do
    @sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date, :title => "a plan for the millenium")
    StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit strategic_plans_strategic_plan_path(:en, StrategicPlan.most_recent.id)
  end

  scenario "add second/lower strategic priority, it's inserted below" do
    add_strategic_priority({:priority_level => "Strategic Priority 2", :description => "We gotta improve"})
    wait_for_ajax
    expect(page.all(".strategic_priority_title .description .no_edit span").map(&:text).first).to eq "Gonna do things betta"
    expect(page.all(".strategic_priority_title .description .no_edit span").map(&:text).last).to eq "We gotta improve"
  end

  scenario "add a second strategic priority that re-orders existing priorities" do
    add_strategic_priority({:priority_level => "Strategic Priority 1", :description => "We gotta improve"})
    wait_for_ajax
    expect(page.all(".strategic_priority_title .priority_level .no_edit span").map(&:text).first).to eq "Strategic Priority 1:"
    expect(page.all(".strategic_priority_title .description .no_edit span").map(&:text).first).to eq "We gotta improve"
    expect(page.all(".strategic_priority_title .priority_level .no_edit span").map(&:text).last).to eq "Strategic Priority 2:"
    expect(page.all(".strategic_priority_title .description .no_edit span").map(&:text).last).to eq "Gonna do things betta"
    expect(page.all(".strategic_priority_title .description .no_edit span").count).to eq 2
    add_strategic_priority({:priority_level => "Strategic Priority 1", :description => "A cauliflower in every pot"})
    wait_for_ajax
    expect(page.all(".strategic_priority_title .priority_level .no_edit span").map(&:text).first).to eq "Strategic Priority 1:"
    expect(page.all(".strategic_priority_title .description .no_edit span").map(&:text).first).to eq "A cauliflower in every pot"
    expect(page.all(".strategic_priority_title .priority_level .no_edit span").map(&:text).second).to eq "Strategic Priority 2:"
    expect(page.all(".strategic_priority_title .description .no_edit span").map(&:text).second).to eq "We gotta improve"
    expect(page.all(".strategic_priority_title .priority_level .no_edit span").map(&:text).third).to eq "Strategic Priority 3:"
    expect(page.all(".strategic_priority_title .description .no_edit span").map(&:text).third).to eq "Gonna do things betta"
    expect(page.all(".strategic_priority_title .description .no_edit span").count).to eq 3
  end
end

feature "editing strategic priorities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPrioritySpecHelpers
  before do
    @sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date, :title => "a plan for the millenium")
    StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit strategic_plans_strategic_plan_path(:en, StrategicPlan.most_recent.id)
  end


  scenario "edit the description and priority level of an existing strategic priority" do
    strategic_priority_edit_icon.click

    select "Strategic Priority 2", :from => 'strategic_priority_priority_level'
    fill_in "strategic_priority_description", :with => "edited description"
    strategic_priority_edit_save_icon.click
    wait_for_ajax

    expect(page).to have_selector(".strategic_priority_title .priority_level .no_edit span", :text => "Strategic Priority 2:")
    expect(page).to have_selector(".strategic_priority_title .description .no_edit span", :text => "edited description")
  end

  scenario "edit to blank description" do
    strategic_priority_edit_icon.click
    select "Strategic Priority 2", :from => 'strategic_priority_priority_level'
    fill_in "strategic_priority_description", :with => ""
    expect{ strategic_priority_edit_save_icon.click; wait_for_ajax }.not_to change{StrategicPriority.first.description}
    expect(page).to have_selector('#description_error', :text => "You must enter a description")
  end

  scenario "edit description and cancel" do
    strategic_priority_edit_icon.click
    select "Strategic Priority 2", :from => 'strategic_priority_priority_level'
    fill_in "strategic_priority_description", :with => "mistake"
    strategic_priority_cancel_edit_icon.click
    expect(page).to have_selector(".strategic_priority_title .description .no_edit span", :text => "Gonna do things betta")
  end

  scenario "edit to blank description, save and cancel" do
    strategic_priority_edit_icon.click
    select "Strategic Priority 2", :from => 'strategic_priority_priority_level'
    fill_in "strategic_priority_description", :with => ""
    strategic_priority_edit_save_icon.click
    wait_for_ajax
    expect(page).to have_selector('#description_error', :text => "You must enter a description")
    strategic_priority_cancel_edit_icon.click
    expect(page).to have_selector(".strategic_priority_title .description .no_edit span", :text => "Gonna do things betta")
    expect(page).not_to have_selector('#description_error', :text => "You must enter a description")
  end
end

feature "deleting strategic priorities", :js => true do
  feature "decrements count in database and view" do
    include LoggedInEnAdminUserHelper # sets up logged in admin user
    include StrategicPrioritySpecHelpers
    before do
      @sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date, :title => "a plan for the millenium")
      FactoryGirl.create(:strategic_priority, :populated, :strategic_plan_id => @sp1.id, :priority_level => 1, :description => "Gonna do things betta")
      FactoryGirl.create(:strategic_priority, :populated, :strategic_plan_id => @sp1.id, :priority_level => 2, :description => "second priority stuff")
      visit strategic_plans_strategic_plan_path(:en, StrategicPlan.most_recent.id)
    end

    scenario "delete a strategic priority" do
      expect{ strategic_priority_delete_icon.first.click; confirm_deletion; wait_for_ajax }.
        to change{StrategicPriority.count}.from(2).to(1)
        .and change{ page.all('.strategic_priority').length }.from(2).to(1)
      sleep(0.4)
      open_strategic_priority
      expect(page.find('.planned_result>.description #edit_start').text).to include PlannedResult.first.description
    end
  end

  feature "remaining strategic priorities retain edit feature" do
    include LoggedInEnAdminUserHelper # sets up logged in admin user
    include StrategicPrioritySpecHelpers
    before do
      @sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date, :title => "a plan for the millenium")
      StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 1, :description => "Gonna do things betta")
      StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 2, :description => "Gonna do things betta")
      StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 3, :description => "Gonna do things betta")
      visit strategic_plans_strategic_plan_path(:en, StrategicPlan.most_recent.id)
    end

    scenario "delete a strategic priority" do
      expect{ second_strategic_priority_delete_icon.click; confirm_deletion; wait_for_ajax }.to change{StrategicPriority.count}.from(3).to(2)
      expect(page).to have_selector('.strategic_priority', :count => 2)
      sleep(0.4)
      second_strategic_priority_edit_icon.click
      expect(page).to have_selector('div.edit.in input#strategic_priority_description')
    end
  end
end
