require "rails_helper"
require File.expand_path('../../helpers/login_helpers',__FILE__)
require File.expand_path('../../helpers/navigation_helpers',__FILE__)
require File.expand_path('../../helpers/user_management_helpers',__FILE__)
require File.expand_path('../../helpers/unactivated_user_helpers',__FILE__)

feature "User management" do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include UserManagementHelpers
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
    fill_in("First name", :with => "Norman")
    fill_in("Last name", :with => "Normal")
    fill_in("Email", :with => "norm@normco.com")
    # ensure that mail was actually sent
    expect{click_button("Save")}.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(page_heading).to eq "User management"
    email = ActionMailer::Base.deliveries.last
    expect( email.subject ).to eq "Please activate your Office of the Ombudsman M & E Database account"
    expect( email.to.first ).to eq "norm@normco.com"
    expect( email.from.first ).to eq "support@www.ombudsman.gov.ws"
    lines = Nokogiri::HTML(email.body.to_s).xpath(".//p").map(&:text)
    # lin[0] is addressee
    expect( lines[0] ).to eq "Norman Normal"
    expect( lines[1] ).to match "Ombudsman M & E Database"
    # activation url is embedded in the email
    url = Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
    expect( url ).to match (/\/en\/authengine\/activate\/[\d|a|b|c|d|e|f]{40}$/) # activation code
    expect( url ).to match (/^http:\/\/www\.ombudsman\.gov\.ws/)
    expect( lines[-1]).to match /M & E Database administrator/
    expect( norman_normal_to_be_in_the_database ).to eq true
    expect( norman_normal_account_is_activated ).to eq false
  end

end

feature "user account activation" do
  include UnactivatedUserHelpers # creates unactivated user
  include UserManagementHelpers
  scenario "user activates account by clicking url in registration email" do
    url = email_activation_link
    visit(url)
    expect(flash_message).to have_text("Your account has been activated")
    expect(page_heading).to match /Welcome \w* \w* to the M & E Database/
    fill_in(:user_login, :with => "norm")
    fill_in(:user_password, :with => "sekret")
    fill_in(:user_password_confirmation, :with => "sekret")
    click_button("Sign up")
    email = ActionMailer::Base.deliveries.last
    expect(page_heading).to eq 'Please log in'
    # not normal action, but we test it anyway, user clicks the activation link again
    visit(url)
    expect(flash_message).to eq 'Your account has already been activated. You can log in below.'
    expect(page_heading).to eq 'Please log in'
    # not normal action, but we test it anyway, user clicks the activation link again
    url_without_activation_code = url.gsub(/[^\/]*$/,'')
    visit(url_without_activation_code )
    expect(flash_message).to eq 'Activation code not found. Please contact database administrator.'
    expect(page_heading).to eq 'Please log in'
    url_with_wrong_activation_code = url.gsub(/[^\/]*$/,'abc123')
    visit url_with_wrong_activation_code
    expect(flash_message).to eq 'Activation code not found. Please contact database administrator.'
    expect(page_heading).to eq 'Please log in'
  end
end

feature "User management" do
  include LoggedInEnAdminUserHelper # logs in as admin
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("User management")
  end

  scenario "reset user password" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link('reset password')
    end
    expect(page_heading).to eq "User management"
    expect(flash_message).to match /A password reset email has been sent to/
  end
end
