require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/corporate_services_admin_spec_helpers'
require 'shared_behaviours/file_admin_behaviour'
require 'file_admin_common_helpers'

feature "internal document admin", :js => true do
  include CorporateServicesAdminSpecHelpers
  include FileAdminCommonHelpers
  it_should_behave_like "file admin"
end

feature "internal document admin when user not permitted", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include CorporateServicesAdminSpecHelpers
  include FileAdminCommonHelpers

  before do
    remove_add_delete_fileconfig_permissions
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf", "doc"]
    visit corporate_services_admin_path('en')
  end

  scenario "update filetypes" do
    within filetypes_context do
      page.find('#filetype_ext').set('docx')
      expect{ new_filetype_button.click; sleep(0.2) }.
        not_to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }
      expect(page.all('.type').map(&:text)).not_to include("docx")
    end
    expect( flash_message ).to eq "You don't have permission to complete that action."
  end

  scenario "delete a filetype" do
    within filetypes_context do
      expect{ delete_filetype("pdf"); sleep(0.2) }.
        not_to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }
      expect(page.all('.type').map(&:text)).to include("pdf")
    end
    expect( flash_message ).to eq "You don't have permission to complete that action."
  end

  scenario "change filesize" do
    visit corporate_services_admin_path('en')
    default_value = page.find('span#filesize').text
    within filesize_context do
      set_filesize("22")
      expect{ page.find('#change_filesize').click; sleep(0.2)}.
        not_to change{ SiteConfig['corporate_services.internal_documents.filesize']}
      expect( page.find('span#filesize').text ).to eq default_value
    end
    expect( flash_message ).to eq "You don't have permission to complete that action."
  end
end

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
