require "rails_helper"
require File.expand_path('../../helpers/login_helpers',__FILE__)
require File.expand_path('../../helpers/navigation_helpers',__FILE__)

feature "User management" do
  include LoggedInAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("User management")
  end

  scenario "navigate to user manaagement page" do
    expect(page_heading).to eq "User management"
    expect(page_title).to eq "User management"
  end

  scenario "add a new user" do
    click_link('New User')
    expect(page_heading).to eq "Create a new user account"
    expect(page_title).to eq "Create a new user account"
  end
end
