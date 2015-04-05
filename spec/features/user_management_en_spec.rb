require "rails_helper"
require File.expand_path('../../helpers/application_helpers',__FILE__)
require File.expand_path('../../helpers/login_helpers',__FILE__)
require File.expand_path('../../helpers/navigation_helpers',__FILE__)
require File.expand_path('../../helpers/user_management_helpers',__FILE__)
require File.expand_path('../../helpers/unactivated_user_helpers',__FILE__)
require File.expand_path('../../helpers/async_helper',__FILE__)
require File.expand_path('../../helpers/role_presets_helper',__FILE__)
require File.expand_path('../../helpers/organization_presets_helper',__FILE__)

feature "Manage users" do
  include ApplicationHelpers
  include RolePresetsHelper
  include OrganizationPresetsHelper
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include UserManagementHelpers
  include AsyncHelper
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Manage users")
  end

  scenario "navigate to user manaagement page" do
    expect(page_heading).to eq "Manage users"
    expect(page_title).to eq "Manage users"
  end

  scenario "add a new user" do
    click_link('New User')
    eventually do
      expect(page_heading).to eq "Create a new user account"
      expect(page_title).to eq "Create a new user account"
    end
    fill_in("First name", :with => "Norman")
    fill_in("Last name", :with => "Normal")
    fill_in("Email", :with => "norm@normco.com")
    # ensure that mail was actually sent
    expect{click_button("Save")}.to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(page_heading).to eq "Manage users"
    email = ActionMailer::Base.deliveries.last
    expect( email.subject ).to eq "Please activate your #{ORGANIZATION_NAME} #{APPLICATION_NAME} account"
    expect( email.to.first ).to eq "norm@normco.com"
    expect( email.from.first ).to eq ADMIN_EMAIL
    lines = Nokogiri::HTML(email.body.to_s).xpath(".//p").map(&:text)
    # lin[0] is addressee
    expect( lines[0] ).to eq "Norman Normal"
    expect( lines[1] ).to match "#{ORGANIZATION_NAME} #{APPLICATION_NAME}"
    # activation url is embedded in the email
    url = Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
    expect( url ).to match (/\/en\/authengine\/activate\/[\d|a|b|c|d|e|f]{40}$/) # activation code
    expect( url ).to match (/^http:\/\/#{SITE_URL}/)
    expect( lines[-1]).to match /#{APPLICATION_NAME} administrator/
    expect( norman_normal_to_be_in_the_database ).to eq true
    expect( norman_normal_account_is_activated ).to eq false
  end

  scenario "show user information" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link("show")
    end
    eventually(:interval => 0.001) do # hack required due to Firefox timing
      expect(page_heading).to eq User.last.first_last_name
    end
    click_link("Back")
    eventually(:interval => 0.001) do # hack required due to Firefox timing
      expect(page_heading).to eq "Manage users"
    end
  end

  scenario "disable a user" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link("disable")
    end
    expect(page.find(:xpath, ".//tr[contains(td[3],'staff')]/td[5]").text ).to match /no/
    expect(page.find(:xpath, ".//tr[contains(td[3],'staff')]/td[6]/a").text ).to eq 'enable'
  end

  scenario "delete a user" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link("delete")
    end
    #page.accept_confirm # requires javascript, but poltergeist ignores modal dialogs!
    eventually do
      expect(page.all(".user").count).to eq 2
    end
  end

  scenario "edit roles for a user", :js => true do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link("edit roles")
    end
    eventually do
      expect(page_heading).to eq "Roles for #{User.last.first_last_name}"
    end
    expect(page.all('#assigned_roles li.name').map(&:text)).to include 'staff [ remove role ]'
    page.find('#available_roles li', :text => 'intern [ assign role ]').find('a').click
    eventually do
      expect(page.all('#assigned_roles li.name').map(&:text)).to include 'intern [ remove role ]'
    end
  end

  scenario "edit roles for a user, and cancel without saving" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link("edit roles")
    end
    eventually do
      expect(page_heading).to eq "Roles for #{User.last.first_last_name}"
    end
    click_link("Back")
    eventually do
      expect(page_heading).to eq "Manage users"
    end
  end

  scenario "edit profile of a user" do
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      click_link("edit profile")
    end
    fill_in "First name", :with => "Anastacia"
    fill_in "Last name", :with => "Friesen"
    fill_in "Email", :with => "ole_medhurst@parisianschamberger.info"
    select "Government of Illyria", :from => "Organization"
    click_button "Save"
    expect(page_heading).to eq "Manage users"
    within(:xpath, ".//tr[contains(td[3],'staff')]") do
      expect( find(:xpath, './td[1]').text ).to eq 'Anastacia'
      expect( find(:xpath, './td[2]').text ).to eq 'Friesen'
    end
  end
end

feature "Edit profile of unactivated user" do
  include UnactivatedUserHelpers # creates unactivated user
  include ApplicationHelpers
  include NavigationHelpers
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Manage users")
  end

  # should not be able to change the profile of an unactivated user
  # as the registration email has already been sent
  # if the email address is a problem, must delete and create new
  scenario "edit profile link should be disabled" do
    within(:xpath, ".//tr[contains(td[3],'intern')]") do
      expect(find('a', :text => "edit profile")).to be_disabled
    end
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
