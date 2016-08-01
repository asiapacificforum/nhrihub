require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/corporate_services_admin_spec_helpers'
require 'shared_behaviours/file_admin_behaviour'
require 'file_admin_common_helpers'

feature "strategic plan admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  scenario "start date not configured" do
    visit corporate_services_admin_path('en')
    expect(page.find('span#start_date').text).to eq "January 1"
    expect(page).to have_select('strategic_plan_start_date_date_2i', :selected => 'January')
    expect(page).to have_select('strategic_plan_start_date_date_3i', :selected => '1')
  end

  scenario "start date already configured" do
    StrategicPlanStartDate.new(:date => Date.new(2001,8,19)).save
    visit corporate_services_admin_path('en')
    expect(page.find('span#start_date').text).to eq "August 19"
    expect(page).to have_select('strategic_plan_start_date_date_2i', :selected => 'August')
    expect(page).to have_select('strategic_plan_start_date_date_3i', :selected => '19')
  end

  scenario "set the date" do
    visit corporate_services_admin_path('en')
    page.select 'April', :from => 'strategic_plan_start_date_date_2i'
    page.select '1', :from => 'strategic_plan_start_date_date_3i'
    page.find('#change_start_date').click; sleep(0.2)
    expect( Date.parse(SiteConfig['corporate_services.strategic_plans.start_date']).strftime("%B %-d") ).to match(/^April 1/)
  end
end
