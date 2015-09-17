require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/media_spec_helper'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaSpecHelpers

  before do
    setup_positivity_ratings
    setup_areas
    FactoryGirl.create(:media_appearance, :hr_area, :positivity_rating => PositivityRating.first, :reminders=>[FactoryGirl.create(:reminder, :media_appearance)] )
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :users => [User.first],
                          :remindable => MediaAppearance.first)
    visit outreach_media_media_appearances_path(:en)
    open_reminders_panel
  end

  scenario "reminders should be displayed" do
    expect(page).to have_selector("#reminders .reminder .reminder_type", :text => "weekly")
    expect(page).to have_selector("#reminders .reminder .text", :text => "don't forget the fruit gums mum")
  end
end
