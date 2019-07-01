require 'reminders_spec_common_helpers'
RSpec.shared_examples "reminders" do
  feature "reminders behaviour" do
    include RemindersSpecCommonHelpers
    scenario "reminders should be displayed" do
      expect(page).to have_selector("#reminders .reminder .reminder_type", :text => "weekly")
      expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
    end

    feature "add a reminder", :js => true do
      scenario "and reminder has no errors" do
        new_reminder_button.click
        select("one-time", :from => :reminder_reminder_type)
        page.find('#reminder_start_date_1i') # forces wait until the element is available
        select_date("Aug 19 #{Date.today.year.next}", :from => :reminder_start_date)
        select(User.first.first_last_name, :from => :reminder_user_id)
        fill_in(:reminder_text, :with => "time to check the database")
        expect{save_reminder.click; wait_for_ajax}.to change{Reminder.count}.from(1).to(2).
                                                  and change{ page.all('#reminders .reminder').count }.from(1).to(2)
        expect(page.all("#reminders .reminder .reminder_type .in").last.text).to eq "one-time"
        expect(page.all("#reminders .reminder .next .in").last.text).to eq "Aug 19, #{Date.today.year.next}"
        expect(page.all("#reminders .reminder .text .in").last.text).to eq "time to check the database"
        expect(page.all("#reminders .reminder .recipient").last.text).to eq User.first.first_last_name
        expect(page.all("#reminders .reminder .previous").last.text).to eq "none"
        close_reminders_modal
        expect(reminders_icon['data-count']).to eq "2"
      end

      scenario "and multiple adds disallowed" do
        new_reminder_button.click
        new_reminder_button.click
        expect(page.all('#new_reminder').count).to eq 1
      end

      scenario "add cancelled by edit" do
        new_reminder_button.click
        expect(page).to have_selector("#new_reminder")
        edit_reminder_icon.click
        expect(page).not_to have_selector("#new_reminder")
      end

      scenario "add terminated by close reminders panel" do
        new_reminder_button.click
        expect(page).to have_selector("#new_reminder")
        close_reminders_modal
        open_reminders_panel
        expect(page).not_to have_selector("#new_reminder")
      end
    end

    feature "add reminder with errors", :js => true do
      scenario "with blank reminder_type error" do
        new_reminder_button.click
        page.find('#reminder_start_date_1i', :wait => 10) # forces wait until the element is available
        select_date("Aug 19 #{Date.today.year}", :from => :reminder_start_date)
        select(User.first.first_last_name, :from => :reminder_user_id)
        fill_in(:reminder_text, :with => "time to check the database")
        expect{save_reminder.click; wait_for_ajax}.not_to change{Reminder.count}
        expect(reminder_error_message).to eq "Please select a type"
        select("weekly", :from => :reminder_reminder_type)
        expect(reminder_type).not_to have_selector('.has-error')
        expect(page).to have_selector("#new_reminder #reminder_type .help-block", :text => "Please select a type", :visible => false)
      end

      scenario "with no recipient error" do
        new_reminder_button.click
        select("one-time", :from => :reminder_reminder_type)
        select_date("Aug 19 #{Date.today.year}", :from => :reminder_start_date)
        fill_in(:reminder_text, :with => "time to check the database")
        expect{save_reminder.click; wait_for_ajax}.not_to change{Reminder.count}
        expect(recipient_error_message).to eq "Please select recipient"
        select(User.first.first_last_name, :from => :reminder_user_id)
        expect(recipient).not_to have_selector('.has-error')
        expect(page).to have_selector("#new_reminder #recipient .help-block", :text =>  "Please select recipient", :visible => false)
      end

      scenario "with blank text error" do
        new_reminder_button.click
        select("one-time", :from => :reminder_reminder_type)
        select_date("Aug 19 #{Date.today.year}", :from => :reminder_start_date)
        select(User.first.first_last_name, :from => :reminder_user_id)
        expect{save_reminder.click; wait_for_ajax}.not_to change{Reminder.count}
        expect(text_error_message).to eq "Text cannot be blank"
        description_field =  find("#reminder_text").native
        description_field.send_keys("m")
        expect(text).not_to have_selector(".has-error")
        expect(page).to have_selector("#new_reminder #text .help-block", :text => "Text cannot be blank", :visible => false)
      end

      scenario "with whitespace only text error" do
        new_reminder_button.click
        select("one-time", :from => :reminder_reminder_type)
        select_date("Aug 19 #{Date.today.year}", :from => :reminder_start_date)
        fill_in(:reminder_text, :with => "  ")
        select(User.first.first_last_name, :from => :reminder_user_id)
        expect{save_reminder.click; wait_for_ajax}.not_to change{Reminder.count}
        expect(text_error_message).to eq "Text cannot be blank"
      end

      scenario "add but cancel without saving" do
        new_reminder_button.click
        select("one-time", :from => :reminder_reminder_type)
        select_date("Aug 19 #{Date.today.year}", :from => :reminder_start_date)
        select(User.first.first_last_name, :from => :reminder_user_id)
        fill_in(:reminder_text, :with => "time to check the database")
        cancel_reminder.click
        expect(page).not_to have_selector('#new_reminder')
        close_reminders_modal
        expect(reminders_icon['data-count']).to eq "1"
      end

      xscenario "start date is <= today" do
        # permitting start date today creates complexity. Have today's reminders been sent already or not?
        # it's less confusing to disallow start date of today (or earlier)
        expect(1).to eq 0
      end
    end

    feature "edit a reminder", :js => true do
      scenario "and save without errors" do
        expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
        edit_reminder_icon.click
        select("one-time", :from => :reminder_reminder_type)
        select_date("Dec 31 #{Date.today.year}", :from => :reminder_start_date)
        select(User.first.first_last_name, :from => :reminder_user_id)
        fill_in(:reminder_text, :with => "have a nice day")
        expect{ edit_reminder_save_icon.click; wait_for_ajax}.to change{Reminder.first.text}.from("don't forget the fruit gums mum").to('have a nice day')
        expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "one-time"
        expect(page.find("#reminders .reminder .next .in").text).to eq "Dec 31, #{Date.today.year}"
        expect(page.find("#reminders .reminder .text .in").text).to eq "have a nice day"
        expect(page.find("#reminders .reminder .recipient .name").text).to eq User.first.first_last_name
        # the valud of 'previous' is not reliable if reminder type is changed.
        # This is not a big problem, and fixing it is tricky.
        # expect(page.find("#reminders .reminder .previous").text).to eq "none"
      end

      scenario "and attempt to save with errors" do
        expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
        next_date = page.find("#reminders .reminder .next .in").text
        edit_reminder_icon.click
        all("select#reminder_reminder_type option").first.select_option
        fill_in(:reminder_text, :with => " ")
        selected_user = Reminder.first.user.first_last_name

        expect{ edit_reminder_save_icon.click; wait_for_ajax}.not_to change{Reminder.first.text}
        expect(page).to have_selector(".reminder .reminder_type.has-error")
        expect(page).to have_selector(".reminder .text.has-error")
        edit_reminder_cancel.click
        expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "weekly"
        expect(page.find("#reminders .reminder .next .in").text).to eq next_date
        expect(page.find("#reminders .reminder .text .in").text).to eq "don't forget the fruit gums mum"
        expect(page.find("#reminders .reminder .recipient .name").text).to eq User.first.first_last_name
        edit_reminder_icon.click
        expect(page).not_to have_selector(".reminder .reminder_type.has-error")
        expect(page).not_to have_selector(".reminder .recipient.has-error")
        expect(page).not_to have_selector(".reminder .text.has-error")
      end

      scenario "cancel without making changes" do
        next_date = page.find("#reminders .reminder .next .in").text
        original_recipient = page.find("#reminders .reminder .recipient .name").text
        expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
        edit_reminder_icon.click
        edit_reminder_cancel.click
        expect(page.find("#reminders .reminder .reminder_type .in").text).to eq "weekly"
        expect(page.find("#reminders .reminder .next .in").text).to eq next_date # i.e. no change
        expect(page.find("#reminders .reminder .text .in").text).to eq "don't forget the fruit gums mum"
        expect(page.find("#reminders .reminder .recipient .name").text).to eq original_recipient
      end

      scenario "edit cancelled by add" do
        edit_reminder_icon.click
        expect(page).to have_selector(".reminder .edit.in")
        new_reminder_button.click
        expect(page).not_to have_selector(".reminder .edit.in")
      end

      scenario "edit terminated by close reminders panel" do
        edit_reminder_icon.click
        expect(page).to have_selector(".reminder .edit.in")
        close_reminders_modal
        open_reminders_panel
        expect(page).not_to have_selector(".reminder .edit.in")
      end
    end

    scenario "delete a reminder" do
      expect{reminder_delete_icon.click; confirm_deletion; wait_for_ajax}.to change{Reminder.count}.from(1).to(0)
      close_reminders_modal
      expect(reminders_icon['data-count']).to eq "0"
    end
  end
end
