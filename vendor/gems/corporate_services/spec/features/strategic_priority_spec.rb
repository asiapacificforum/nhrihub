require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "adding strategic priorities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    visit corporate_services_strategic_plan_path(:en, "current")
  end

  scenario "add strategic priority" do
    add_strategic_priority({:priority_level => "Strategic Priority 1", :description => "The application of good governance by public authorities"})
    expect(page).to have_selector("[data-editable_attribute='description'] .no_edit", :text => "The application of good governance by public authorities")
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
    expect(page).to have_selector('.new_strategic_priority .error', :text => "You must select the priority level")
  end

  scenario "submit with errors: no description entered" do
    expect{ add_strategic_priority({:priority_level => "Strategic Priority 1"}) }.not_to change{ StrategicPriority.count }
    expect(page).to have_selector('.new_strategic_priority .error', :text => "You must enter a description")
  end

  scenario "click 'Add strategic priority' more than once without submitting" do
    add_priority_button.click
    add_priority_button.click
    expect(page).to have_selector('form#new_strategic_priority', :count => 1)
  end
end

feature "strategic plan multiple strategic priorities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    @sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit corporate_services_strategic_plan_path(:en, "current")
  end

  scenario "add second/lower strategic priority, it's inserted below" do
    add_strategic_priority({:priority_level => "Strategic Priority 2", :description => "We gotta improve"})
    sleep(0.1)
    expect(page.all("[data-editable_attribute='description'] .no_edit").map(&:text).first).to eq "Gonna do things betta"
    expect(page.all("[data-editable_attribute='description'] .no_edit").map(&:text).last).to eq "We gotta improve"
  end

  scenario "add a second strategic priority that re-orders existing priorities" do
    add_strategic_priority({:priority_level => "Strategic Priority 1", :description => "We gotta improve"})
    sleep(0.1)
    expect(page.all("[data-editable_attribute='priority_level'] .no_edit").map(&:text).first).to eq "Strategic Priority 1:"
    expect(page.all("[data-editable_attribute='description'] .no_edit").map(&:text).first).to eq "We gotta improve"
    expect(page.all("[data-editable_attribute='priority_level'] .no_edit").map(&:text).last).to eq "Strategic Priority 2:"
    expect(page.all("[data-editable_attribute='description'] .no_edit").map(&:text).last).to eq "Gonna do things betta"
  end
end

feature "modifying strategic priorities", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    @sp1 = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    StrategicPriority.create(:strategic_plan_id => @sp1.id, :priority_level => 1, :description => "Gonna do things betta")
    visit corporate_services_strategic_plan_path(:en, "current")
  end


  scenario "edit the description and priority level of an existing strategic priority" do
    edit_icon.click

    select "Strategic Priority 2", :from => 'strategic_priority_priority_level'
    fill_in "strategic_priority_description", :with => "edited description"
    page.find('.edit-save').click
    sleep(0.2)

    expect(page).to have_selector("[data-editable_attribute='priority_level'] .no_edit", :text => "Strategic Priority 2:")
    expect(page).to have_selector("[data-editable_attribute='description'] .no_edit", :text => "edited description")
  end

  scenario "delete a strategic priority" do
    expect{ delete_icon.click; sleep(0.2) }.to change{StrategicPriority.count}.from(1).to(0)
    expect(page).not_to have_selector('.strategic_priority')
  end
end

def edit_icon
  page.find('i#edit_start')
end

def delete_icon
  page.find('i#delete')
end

def open_accordion_for_strategic_priority_one
  page.find("[data-editable_attribute='description'] .no_edit", :text => "Gonna do things betta").click
end

def add_priority_button
  page.find('.add_strategic_priority')
end

def add_strategic_priority(attrs)
  add_priority_button.click
  sleep(0.1)
  within "form#new_strategic_priority" do
    select attrs[:priority_level].to_s, :from => 'strategic_priority_priority_level' if attrs[:priority_level]
    fill_in "strategic_priority_description", :with => attrs[:description] if attrs[:description]
    page.find('#edit-save').click
    sleep(0.2)
  end
end
