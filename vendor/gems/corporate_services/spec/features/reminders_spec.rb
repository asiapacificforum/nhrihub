require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    act = Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
    rem = Reminder.create(:reminder_type => 'weekly', :start_date => Date.new(2015,8,19), :text => "don't forget the fruit gums mum", :users => [User.first], :activity => act)
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    reminders_icon.click
  end

  scenario "reminders should be displayed" do
    expect(page).to have_selector("#reminders .reminder .reminder_type", :text => "weekly")
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
  end
end


feature "add a reminder", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  before do
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    o.activities << Activity.new(:description => "Smarter thinking")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    reminders_icon.click
  end

  scenario "and reminder has no errors" do
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("August 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "time to check the database")
    expect{save_reminder.click; sleep(0.2)}.to change{Reminder.count}.from(0).to(1)
    expect(page.find("#reminders .reminder .reminder_type").text).to eq "one-time"
    expect(page.find("#reminders .reminder .next").text).to eq "August 19, 2015"
    expect(page.find("#reminders .reminder .text").text).to eq "time to check the database"
    expect(page.find("#reminders .reminder .recipient").text).to eq User.first.first_last_name
    expect(page.find("#reminders .reminder .previous").text).to eq "none"
  end

  scenario "and multiple adds disallowed" do
    new_reminder_button.click
    new_reminder_button.click
    expect(page.all('#new_reminder').count).to eq 1
  end

  xscenario "and reminder type is rule" do

  end

  scenario "with blank reminder_type error" do
    new_reminder_button.click
    select_date("August 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "time to check the database")
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(page).to have_selector("#new_reminder #reminder_type.has-error .help-block", :text => "Please select a type")
    select("weekly", :from => :reminder_reminder_type)
    expect(page).not_to have_selector("#new_reminder #reminder_type.has-error .help-block", :text => "Please select a type")
    expect(page).to have_selector("#new_reminder #reminder_type .help-block", :text => "Please select a type", :visible => false)
  end

  scenario "with no recipients error" do
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("August 19 2015", :from => :reminder_start_date)
    fill_in(:reminder_text, :with => "time to check the database")
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(page).to have_selector("#new_reminder #recipients.has-error .help-block", :text => "Please select recipient(s)")
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect(page).not_to have_selector("#new_reminder #recipients.has-error .help-block", :text => "Please select recipient(s)")
    expect(page).to have_selector("#new_reminder #recipients .help-block", :text =>  "Please select recipient(s)", :visible => false)
  end

  scenario "with blank text error" do
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("August 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(page).to have_selector("#new_reminder #text.has-error .help-block", :text => "Text cannot be blank")
    description_field =  find("#reminder_text").native
    description_field.send_keys("m")
    expect(page).not_to have_selector("#new_reminder #text.has-error .help-block", :text => "Text cannot be blank")
    expect(page).to have_selector("#new_reminder #text .help-block", :text => "Text cannot be blank", :visible => false)
  end

  scenario "with whitespace only text error" do
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("August 19 2015", :from => :reminder_start_date)
    fill_in(:reminder_text, :with => "  ")
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(page).to have_selector("#new_reminder #text.has-error .help-block", :text => "Text cannot be blank")
  end

  xscenario "add but cancel without saving" do
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("August 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "time to check the database")
    cancel_reminder.click
    expect(page).not_to have_selector('#new_reminder')
  end
end

feature "edit a reminder", :js => true do
end

feature "delete a reminder", :js => true do
end

feature "review existing reminders", :js => true do
end

def select_date(date,options)
  base = options[:from].to_s
  year_selector = base+"_1i"
  month_selector = base+"_2i"
  day_selector = base+"_3i"
  month,day,year = date.split(' ')
  select(year, :from => year_selector)
  select(month, :from => month_selector)
  select(day, :from => day_selector)
end

def reminders_icon
  page.find(".row.activity div.actions div.alarm_icon")
end

def save_reminder
  page.find("i#save_reminder")
end

def new_reminder_button
  page.find("i#add_reminder")
end

def open_accordion_for_strategic_priority_one
  page.find("i#toggle").click
end
