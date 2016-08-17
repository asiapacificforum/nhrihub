require "rails_helper"
require 'login_helpers'
require 'navigation_helpers'

feature "Manage users" do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Manage roles")
  end

  scenario "add a new role" do
    click_link "Add new role"
    fill_in("Name", :with => "intern")
    select("admin", :from => "Parent")
    click_button("Save")
    expect(page.all('table tr.role').count).to eq 3
    expect(page.all('table tr.role td.name').map(&:text)).to include "intern"
  end
end
