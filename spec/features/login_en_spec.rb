require "rails_helper"
require File.expand_path('../../helpers/login_helpers',__FILE__)

feature "Unregistered user tries to log in" do
  scenario "navigation not available before user logs in" do
    visit "/en"
    expect(page_heading).to eq "Please log in"
    expect(page).not_to have_selector(".nav")
  end

  scenario "admin logs in" do
    visit "/en"

    fill_in "User name", :with => "admin"
    fill_in "Password", :with => "password"
    click_button "Log in..."

    expect(flash_message).to have_text("Your username or password is incorrect.")
    expect(page).not_to have_selector(".nav")
    expect(page_heading).to eq "Please log in"
  end
end

feature "Registered user logs in with valid credentials", :js => true do
  include RegisteredUserHelper
  scenario "admin logs in" do
    visit "/en"

    fill_in "User name", :with => "admin"
    fill_in "Password", :with => "password"
    click_button "Log in..."

    expect(flash_message).to have_text("Logged in successfully")
    expect(navigation_menu).to include("Admin")
    expect(navigation_menu).to include("Logout")
  end

  scenario "staff member logs in" do
    visit "/en"

    fill_in "User name", :with => "staff"
    fill_in "Password", :with => "password"
    click_button "Log in..."

    expect(flash_message).to have_text("Logged in successfully")
    expect(navigation_menu).not_to include("Admin")
    expect(navigation_menu).to include("Logout")
  end
end

feature "Registered user logs in with invalid credentials" do
  include RegisteredUserHelper
  scenario "enters bad password" do
    visit "/en"

    fill_in "User name", :with => "admin"
    fill_in "Password", :with => "badpassword"
    click_button "Log in..."

    expect(flash_message).to have_text("Your username or password is incorrect.")
    expect(page_heading).to eq "Please log in"
  end

  scenario "enters bad user name" do
    visit "/en"

    fill_in "User name", :with => "notavaliduser"
    fill_in "Password", :with => "password"
    click_button "Log in..."

    expect(flash_message).to have_text("Your username or password is incorrect.")
    expect(page_heading).to eq "Please log in"
    expect(page).not_to have_selector(".nav")
  end
end
