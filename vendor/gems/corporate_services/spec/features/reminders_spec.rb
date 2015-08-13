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
    select_date("Aug 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "time to check the database")
    save_reminder.click
    sleep(0.2)
    expect(Reminder.count).to eq 1
    #expect{save_reminder.click; sleep(0.2)}.to change{Reminder.count}.from(0).to(1)
    expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "one-time"
    expect(page.find("#reminders .reminder .next .in").text).to eq "Aug 19, 2015"
    expect(page.find("#reminders .reminder .text .in").text).to eq "time to check the database"
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
    select_date("Aug 19 2015", :from => :reminder_start_date)
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
    select_date("Aug 19 2015", :from => :reminder_start_date)
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
    select_date("Aug 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect{save_reminder.click; sleep(0.3)}.not_to change{Reminder.count}
    expect(page).to have_selector("#new_reminder #text.has-error .help-block", :text => "Text cannot be blank")
    description_field =  find("#reminder_text").native
    description_field.send_keys("m")
    expect(page).not_to have_selector("#new_reminder #text.has-error .help-block", :text => "Text cannot be blank")
    expect(page).to have_selector("#new_reminder #text .help-block", :text => "Text cannot be blank", :visible => false)
  end

  scenario "with whitespace only text error" do
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("Aug 19 2015", :from => :reminder_start_date)
    fill_in(:reminder_text, :with => "  ")
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(page).to have_selector("#new_reminder #text.has-error .help-block", :text => "Text cannot be blank")
  end

  scenario "add but cancel without saving" do
    new_reminder_button.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("Aug 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "time to check the database")
    cancel_reminder.click
    expect(page).not_to have_selector('#new_reminder')
  end
end

feature "edit a reminder", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    FactoryGirl.create(:user, :firstName => 'Norman', :lastName => 'Normal')
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    activity = Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
    activity.reminders << Reminder.create(:reminder_type => 'quarterly', :start_date => Date.new(2014,8,1), :text => "don't forget to do something")
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    reminders_icon.click
  end

  scenario "and save without errors" do
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget to do something")
    edit_reminder_icon.click
    #edit_reminder_icon.trigger('click')
    select("one-time", :from => :reminder_reminder_type)
    select_date("Dec 25 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    select(User.last.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "have a nice day")
    edit_reminder_save_icon.click
    #edit_reminder_save_icon.trigger('click')
    sleep(0.2)
    expect(Reminder.first.text).to eq "have a nice day"
    #expect{ edit_reminder_save_icon.trigger('click'); sleep(0.2)}.to change{Reminder.first.text}
    expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "one-time"
    expect(page.find("#reminders .reminder .next .in").text).to eq "Dec 25, 2015"
    expect(page.find("#reminders .reminder .text .in").text).to eq "have a nice day"
    expect(page.all("#reminders .reminder .recipient").map(&:text)).to include User.first.first_last_name
    expect(page.all("#reminders .reminder .recipient").map(&:text)).to include User.last.first_last_name
    expect(page.find("#reminders .reminder .previous").text).to eq "none"
  end

  scenario "and attempt to save with errors" do
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget to do something")
    edit_reminder_icon.click
    #edit_reminder_icon.trigger('click')
    all("select#reminder_reminder_type option").first.select_option
    fill_in(:reminder_text, :with => " ")
    unselect("Norman Normal", :from => :reminder_user_ids)
    #edit_reminder_save_icon.trigger('click')
    edit_reminder_save_icon.click
    sleep(0.2)
    expect(Reminder.first.text).to eq "don't forget to do something"
    #expect{ edit_reminder_save_icon.trigger('click'); sleep(0.2)}.not_to change{Reminder.first.text}
    expect(page).to have_selector(".reminder .reminder_type.has-error")
    expect(page).to have_selector(".reminder .recipients.has-error")
    expect(page).to have_selector(".reminder .text.has-error")
  end
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

def edit_reminder_icon
  page.find(:xpath, ".//i[@id='reminder_editable1_edit_start']")
end

def edit_reminder_save_icon
  page.find(:xpath, ".//i[@id='reminder_editable1_edit_save']")
end

def save_reminder
  page.find("i#save_reminder")
end

def cancel_reminder
  page.find("i#cancel_reminder")
end

def new_reminder_button
  page.find("i#add_reminder")
end

def open_accordion_for_strategic_priority_one
  page.find("i#toggle").click
end
