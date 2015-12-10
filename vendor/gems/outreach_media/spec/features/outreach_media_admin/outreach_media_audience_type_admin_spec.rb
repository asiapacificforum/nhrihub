require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/media_admin_spec_helpers'

feature "configure audience types", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaAdminSpecHelpers

  before do
    setup_default_audience_types
    visit outreach_media_admin_path('en')
    expect(page).to have_selector('h4', :text => "Outreach audience types")
  end

  scenario 'view default audience types' do
    expect(page).to have_selector('#audience_types .audience_type', :count => 8)
    expect(audience_types_long_descriptions).to include 'Police'
    expect(audience_types_short_descriptions).to include 'NGO'
  end

  scenario 'add an audience type' do
    fill_in('audience_type_short_type', :with => 'ABC')
    fill_in('audience_type_long_type', :with => 'A few words')
    expect{add_audience_type.click; sleep(0.4)}.to change{AudienceType.count}.by(1)
    sleep(0.4)
    expect(page).to have_selector('#audience_types .audience_type', :count => 9)
    expect(audience_types_long_descriptions).to include 'A few words'
    expect(audience_types_short_descriptions).to include 'ABC'
  end

  scenario 'add an audience type with blank text' do
    fill_in('audience_type_short_type', :with => '')
    fill_in('audience_type_long_type', :with => '')
    expect{add_audience_type.click; sleep(0.4)}.not_to change{AudienceType.count}
    expect(page).to have_selector('#audience_types .audience_type', :count => 8)
    expect(page).to have_selector('#type_error', :text => 'You must provide a short description and/or a long description')
  end

  scenario 'add an audience type with whitespace text' do
    fill_in('audience_type_short_type', :with => '  ')
    fill_in('audience_type_long_type', :with => '  ')
    expect{add_audience_type.click; sleep(0.4)}.not_to change{AudienceType.count}
    expect(page).to have_selector('#audience_types .audience_type', :count => 8)
    expect(page).to have_selector('#type_error', :text => 'You must provide a short description and/or a long description')
  end

  scenario 'audience type error message removed on keydown' do
    fill_in('audience_type_short_type', :with => '  ')
    fill_in('audience_type_long_type', :with => '  ')
    add_audience_type.click
    expect(page).to have_selector('#type_error', :text => 'You must provide a short description and/or a long description')
    fill_in('audience_type_short_type', :with => 'x')
    expect(page).not_to have_selector('#type_error', :text => 'You must provide a short description and/or a long description')
  end

  scenario 'delete an audience type' do
    expect{delete_first_audience_type; sleep(0.4)}.to change{AudienceType.count}.by(-1)
    expect(page).to have_selector('#audience_types .audience_type', :count => 7)
  end
end
