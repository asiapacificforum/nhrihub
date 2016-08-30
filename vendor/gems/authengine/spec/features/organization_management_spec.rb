require "rails_helper"
require 'application_helpers'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/user_management_helpers'
require 'unactivated_user_helpers'
require 'async_helper'
require 'role_presets_helper'
require 'organization_presets_helper'

feature "Manage organizations:", :js => true do
  #include ApplicationHelpers
  #include RolePresetsHelper
  include OrganizationPresetsHelper
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  #include AsyncHelper

  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Manage organizations")
  end

  scenario "view organizations" do
    expect(page_heading).to eq "Organizations list"
    expect(page.all(:css,'table#organizations tr.organization td.organization_name a').map(&:text)).to include 'Government of Illyria'
  end

  scenario "add an organization", :js => true do
    click_link('Add organization')
    expect(page_heading).to eq "New organization"
    fill_in("Organization name", :with => "Acme Corp")
    fill_in("Street", :with => "234 Gravenstein Highway")
    fill_in("City", :with => "New York")
    fill_in("State", :with => "California")
    fill_in("Postcode", :with => 12343)
    fill_in("Email", :with => "foo@barco.com")
    fill_in("Phone number", :with => "828-555-1287")
    click_link("add another phone number")
    # there are now two phone number fields, so it's not so pretty!
    page.all(:fillable_field, "Phone number").last.set("637-298-1255")
    click_button("Save")
    expect(page_heading).to eq "Organizations list"
    expect(page.all('td.organization_name').map(&:text) ).to include "Acme Corp"
    expect(Organization.last.contacts.map(&:phone)).to include "828-555-1287"
    expect(Organization.last.contacts.map(&:phone)).to include "637-298-1255"
  end
end

feature "Manage an existing organizations", :js => true do
  #include ApplicationHelpers
  #include RolePresetsHelper
  include OrganizationPresetsHelper
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include AsyncHelper # 'eventually' method

  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Manage organizations")
  end

  scenario "remove an organization with no users" do
    expect(page_heading).to eq 'Organizations list'
    selector = ".//tr[@class='organization'][contains(td/a,'Government of Maldonia')]"
    if page.driver.browser.is_a? Capybara::Poltergeist::Browser
      within(:xpath, selector) do
        click_link('delete')
      end
    else
      page.accept_alert 'Are you sure?' do
        within(:xpath, selector) do
          click_link('delete')
        end
      end
    end
    expect(page).not_to have_selector(:xpath, selector)
  end

  scenario "remove an organization with users" do
    expect(page_heading).to eq 'Organizations list'
    selector = ".//tr[@class='organization'][contains(td/a,'Government of Illyria')]"
    within(:xpath, selector) do
      click_link('delete')
    end
    expect(page).to have_selector(:xpath, selector)
  end

  scenario "edit an organization" do
    expect(page_heading).to eq 'Organizations list'
    selector = ".//tr[@class='organization'][contains(td/a,'Government of Illyria')]"
    within(:xpath, selector) do
      click_link('edit')
    end
    eventually do
      expect(page_heading).to eq 'Edit organization'
    end
    click_link("add another phone number")
    page.all(:fillable_field, "Phone number").last.set("637-298-1255")
    click_button("Save")
    expect(flash_message).to eq 'Organization updated'
    expect(Organization.first.contacts.length).to eq 3
    expect(Organization.first.contacts.map(&:phone)).to include "637-298-1255"
  end

  scenario "show organization information" do
    expect(page_heading).to eq 'Organizations list'
    selector = ".//tr[@class='organization']/td/a[contains(.,'Government of Illyria')]"
    page.find(:xpath, selector).click
    expect(page_heading).to eq "Organization: Government of Illyria"
    expect(page.find('#name').text).to eq "Government of Illyria"
    expect(page.find('#street').text).to eq "38 Powis Square"
    expect(page.find('#city').text).to eq "Notting Hill"
    expect(page.find('#state').text).to eq "Amnesia"
    expect(page.find('#zip').text).to eq "12345"
    expect(page.find('#phone').text).to match "862-385-1818"
    expect(page.find('#phone').text).to match "489-733-4829"
    expect(page.find('#email').text).to eq "kahuna@bigbrother.gov"
  end
end
