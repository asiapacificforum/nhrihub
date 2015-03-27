require "rails_helper"
require File.expand_path('../../helpers/login_helpers',__FILE__)
require File.expand_path('../../helpers/navigation_helpers',__FILE__)
require File.expand_path('../../helpers/user_management_helpers',__FILE__)
#require File.expand_path('../../helpers/unactivated_user_helpers',__FILE__)

feature "Password management" do
  include LoggedInEnAdminUserHelper # logs in as admin
  include NavigationHelpers
  include UserManagementHelpers
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Manage users")
  end

  scenario "admin resets user password" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    expect(page_heading).to eq "Manage users"
    expect(flash_message).to match /A password reset email has been sent to/
    click_link('Logout')
    # user whose password was reset responds to the link in the email
    visit(new_password_activation_link)
    expect(page_heading).to match /Select new password for/
    fill_in("Enter a new password", :with => "shinynewsecret")
    fill_in("Re-enter the password to confirm", :with => "shinynewsecret")
    click_button("Submit")
    expect(flash_message).to eq "Your new password has been saved, you may login below."
    fill_in "User name", :with => "staff"
    fill_in "Password", :with => "shinynewsecret"
    click_button "Log in..."
    expect(flash_message).to eq "Logged in successfully"
  end

  scenario "reset user password, user enters different passwords" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    expect(page_heading).to eq "Manage users"
    expect(flash_message).to match /A password reset email has been sent to/
    click_link('Logout')
    # user whose password was reset responds to the link in the email
    visit(new_password_activation_link)
    expect(page_heading).to match /Select new password for/
    fill_in("Enter a new password", :with => "shinynewsecret")
    fill_in("Re-enter the password to confirm", :with => "differentsecret")
    click_button("Submit")
    expect(page_heading).to match /Select new password for/
    expect(flash_message).to eq "Password confirmation doesn't match password, please try again."
  end

  scenario "reset user password, user uses incorrect password reset_token" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    click_link('Logout')

    # user whose password was reset responds to the link in the email
    url_with_bogus_password_reset_token = new_password_activation_link.gsub(/[^\/]*$/,'bogus_password_reset_code')
    visit(url_with_bogus_password_reset_token  )
    expect(flash_message).to eq "User not found"
  end

  scenario "reset user password, user uses blank password reset token" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    click_link('Logout')

    # user whose password was reset responds to the link in the email
    url_with_bogus_password_reset_token = new_password_activation_link.gsub(/[^\/]*$/,'')
    visit(url_with_bogus_password_reset_token  )
    expect(flash_message).to eq "Invalid password reset."
  end
end
