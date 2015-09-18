require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/setup_helper'
require_relative '../helpers/reminders_spec_helper'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include SetupHelper
  include RemindersSpecHelpers

  before do
    setup_database
    visit outreach_media_media_appearances_path(:en)
    open_reminders_panel
  end

  scenario "reminders should be displayed" do
    expect(page).to have_selector("#reminders .reminder .reminder_type", :text => "weekly")
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
  end
end
