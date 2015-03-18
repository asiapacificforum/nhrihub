require "rails_helper"
require File.expand_path('../../helpers/login_helpers',__FILE__)
require File.expand_path('../../helpers/navigation_helpers',__FILE__)

feature "User management" do
  include LoggedInAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  scenario "navigate to user manaagement page" do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("User management")
    expect(page_heading).to eq "User management"
    expect(page_title).to eq "User management"
  end
end
