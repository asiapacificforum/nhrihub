require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "internal document management" do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Corporate Services")
    select_dropdown_menu_item("Internal documents")
  end

  scenario "add a new document" do
    expect(page_heading).to eq "Internal Documents"
    expect(page_title).to eq "Internal Documents"
    add_document_link.click
  end
end

def add_document_link
  page.find('a#add_document')
end
