require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/reminder_page_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/setup_helpers'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ReminderPageHelpers
  include StrategicPlanHelpers
  include SetupHelpers

  before do
    activity = setup_activity
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :users => [User.first], :remindable => activity)
    open_reminders_panel
  end

  scenario "reminders should be displayed" do
    expect(page).to have_selector("#reminders .reminder .reminder_type", :text => "weekly")
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
  end
end


feature "add a reminder", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ReminderPageHelpers
  include StrategicPlanHelpers
  include SetupHelpers

  before do
    setup_activity
    open_reminders_panel
  end

  scenario "and reminder has no errors" do
    new_reminder_button.click
    sleep(0.2)
    select("one-time", :from => :reminder_reminder_type)
    select_date("Aug 19 2017", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "time to check the database")
    expect{save_reminder.click; sleep(0.2)}.to change{Reminder.count}.from(0).to(1)
    expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "one-time"
    expect(page.find("#reminders .reminder .next .in").text).to eq "Aug 19, 2017"
    expect(page.find("#reminders .reminder .text .in").text).to eq "time to check the database"
    expect(page.find("#reminders .reminder .recipient").text).to eq User.first.first_last_name
    expect(page.find("#reminders .reminder .previous").text).to eq "none"
  end

  scenario "and multiple adds disallowed" do
    new_reminder_button.click
    sleep(0.2)
    new_reminder_button.click
    sleep(0.2)
    expect(page.all('#new_reminder').count).to eq 1
  end

  scenario "with blank reminder_type error" do
    new_reminder_button.click
    sleep(0.2)
    select_date("Aug 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "time to check the database")
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(reminder_error_message).to eq "Please select a type"
    select("weekly", :from => :reminder_reminder_type)
    expect(reminder_type).not_to have_selector('.has-error')
    expect(page).to have_selector("#new_reminder #reminder_type .help-block", :text => "Please select a type", :visible => false)
  end

  scenario "with no recipients error" do
    new_reminder_button.click
    sleep(0.3)
    select("one-time", :from => :reminder_reminder_type)
    select_date("Aug 19 2015", :from => :reminder_start_date)
    fill_in(:reminder_text, :with => "time to check the database")
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(recipients_error_message).to eq "Please select recipient(s)"
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect(recipients).not_to have_selector('.has-error')
    expect(page).to have_selector("#new_reminder #recipients .help-block", :text =>  "Please select recipient(s)", :visible => false)
  end

  scenario "with blank text error" do
    new_reminder_button.click
    sleep(0.4)
    select("one-time", :from => :reminder_reminder_type)
    select_date("Aug 19 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect{save_reminder.click; sleep(0.3)}.not_to change{Reminder.count}
    sleep(0.2)
    expect(text_error_message).to eq "Text cannot be blank"
    description_field =  find("#reminder_text").native
    description_field.send_keys("m")
    expect(text).not_to have_selector(".has-error")
    expect(page).to have_selector("#new_reminder #text .help-block", :text => "Text cannot be blank", :visible => false)
  end

  scenario "with whitespace only text error" do
    new_reminder_button.click
    sleep(0.2)
    select("one-time", :from => :reminder_reminder_type)
    select_date("Aug 19 2015", :from => :reminder_start_date)
    fill_in(:reminder_text, :with => "  ")
    select(User.first.first_last_name, :from => :reminder_user_ids)
    expect{save_reminder.click; sleep(0.2)}.not_to change{Reminder.count}
    expect(text_error_message).to eq "Text cannot be blank"
  end

  scenario "add but cancel without saving" do
    new_reminder_button.click
    sleep(0.2)
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
  include ReminderPageHelpers
  include StrategicPlanHelpers
  include SetupHelpers

  before do
    FactoryGirl.create(:user, :firstName => 'Norman', :lastName => 'Normal')
    activity = setup_activity
    activity.reminders << Reminder.create(:reminder_type => 'quarterly', :start_date => Date.new(2014,8,1), :text => "don't forget to do something", :users => [User.first])
    open_reminders_panel
  end

  scenario "and save without errors" do
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget to do something")
    edit_reminder_icon.click
    select("one-time", :from => :reminder_reminder_type)
    select_date("Dec 25 2015", :from => :reminder_start_date)
    select(User.first.first_last_name, :from => :reminder_user_ids)
    select(User.last.first_last_name, :from => :reminder_user_ids)
    fill_in(:reminder_text, :with => "have a nice day")
    #edit_reminder_save_icon.click
    #expect{ edit_reminder_save_icon.trigger('click'); sleep(0.2)}.to change{Reminder.first.text}.to('have a nice day')
    expect{ edit_reminder_save_icon.click; sleep(0.2)}.to change{Reminder.first.text}.from("don't forget to do something").to('have a nice day')
    expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "one-time"
    expect(page.find("#reminders .reminder .next .in").text).to eq "Dec 25, 2015"
    expect(page.find("#reminders .reminder .text .in").text).to eq "have a nice day"
    expect(page.all("#reminders .reminder .recipient").map(&:text)).to include User.first.first_last_name
    expect(page.all("#reminders .reminder .recipient").map(&:text)).to include User.last.first_last_name
    expect(page.find("#reminders .reminder .previous").text).to eq "none"
  end

  scenario "and attempt to save with errors" do
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget to do something")
    next_date = page.find("#reminders .reminder .next .in").text
    edit_reminder_icon.click
    all("select#reminder_reminder_type option").first.select_option
    fill_in(:reminder_text, :with => " ")
    unselect(User.first.first_last_name, :from => :reminder_user_ids)
    #expect{ edit_reminder_save_icon.trigger('click'); sleep(0.2)}.not_to change{Reminder.first.text}
    expect{ edit_reminder_save_icon.click; sleep(0.2)}.not_to change{Reminder.first.text}
    expect(page).to have_selector(".reminder .reminder_type.has-error")
    expect(page).to have_selector(".reminder .recipients.has-error")
    expect(page).to have_selector(".reminder .text.has-error")
    edit_reminder_cancel.click
    sleep(0.4) #js transition
    expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "quarterly"
    expect(page.find("#reminders .reminder .next .in").text).to eq next_date
    expect(page.find("#reminders .reminder .text .in").text).to eq "don't forget to do something"
    expect(page.all("#reminders .reminder .recipient").map(&:text)).to include User.first.first_last_name
  end

  scenario "cancel without making changes" do
    next_date = page.find("#reminders .reminder .next .in").text
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget to do something")
    edit_reminder_icon.click
    sleep(0.2) #js transition
    edit_reminder_cancel.click
    sleep(0.2) #js transition
    expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "quarterly"
    expect(page.find("#reminders .reminder .next .in").text).to eq next_date # i.e. no change
    expect(page.find("#reminders .reminder .text .in").text).to eq "don't forget to do something"
    expect(page.all("#reminders .reminder .recipient").map(&:text)).to include User.first.first_last_name
  end
end

feature "delete a reminder", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ReminderPageHelpers
  include StrategicPlanHelpers
  include SetupHelpers

  before do
    activity = setup_activity
    activity.reminders << Reminder.create(:reminder_type => 'quarterly', :start_date => Date.new(2014,8,1), :text => "don't forget to do something")
    open_reminders_panel
  end

  scenario "delete" do
    expect{reminder_delete_icon.click; sleep(0.2)}.to change{Reminder.count}.from(1).to(0)
  end
end
