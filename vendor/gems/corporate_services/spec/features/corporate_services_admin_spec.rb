require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/corporate_services_admin_spec_helpers'

feature "internal document admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include CorporateServicesAdminSpecHelpers

  scenario "no filetypes configured" do
    visit corporate_services_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "filetypes configured" do
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf"]
    visit corporate_services_admin_path('en')
    expect(page.find('.type').text).to eq 'pdf'
  end

  scenario "add filetype" do
    visit corporate_services_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
    page.find('#filetype_ext').set('docx')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }.from([]).to(["docx"])
    expect(page).not_to have_selector '#empty'
    page.find('#filetype_ext').set('ppt')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ SiteConfig['corporate_services.internal_documents.filetypes'].length }.from(1).to(2)
  end

  scenario "add duplicate filetype" do
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf", "doc"]
    visit corporate_services_admin_path('en')
    sleep(0.1)
    page.find('#filetype_ext').set('doc')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }
    expect( flash_message ).to eq "Filetype already exists, must be unique."
  end

  scenario "add duplicate filetype" do
    visit corporate_services_admin_path('en')
    sleep(0.1)
    page.find('#filetype_ext').set('a_very_long_filename')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }
    expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
  end

  scenario "delete a filetype" do
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf", "doc"]
    visit corporate_services_admin_path('en')
    delete_filetype("pdf")
    sleep(0.2)
    expect( SiteConfig['corporate_services.internal_documents.filetypes'] ).to eq ["doc"]
    delete_filetype("doc")
    sleep(0.2)
    expect( SiteConfig['corporate_services.internal_documents.filetypes'] ).to eq []
    expect(page).to have_selector '#empty'
  end

  scenario "change filesize" do
    visit corporate_services_admin_path('en')
    set_filesize("22")
    expect{ page.find('#change_filesize').click; sleep(0.2)}.
      to change{ SiteConfig['corporate_services.internal_documents.filesize']}.to(22)
    expect( page.find('span#filesize').text ).to eq "22"
  end
end

feature "internal document admin when user not permitted", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include CorporateServicesAdminSpecHelpers

  before do
    remove_add_delete_fileconfig_permissions
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf", "doc"]
    visit corporate_services_admin_path('en')
  end

  scenario "update filetypes" do
    page.find('#filetype_ext').set('docx')
    expect{ new_filetype_button.click; sleep(0.2) }.
      not_to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }
    expect( flash_message ).to eq "You don't have permission to complete that action."
    expect(page.all('.type').map(&:text)).not_to include("docx")
  end

  scenario "delete a filetype" do
    expect{ delete_filetype("pdf"); sleep(0.2) }.
      not_to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }
    expect( flash_message ).to eq "You don't have permission to complete that action."
    expect(page.all('.type').map(&:text)).to include("pdf")
  end

  scenario "change filesize" do
    visit corporate_services_admin_path('en')
    default_value = page.find('span#filesize').text
    set_filesize("22")
    expect{ page.find('#change_filesize').click; sleep(0.2)}.
      not_to change{ SiteConfig['corporate_services.internal_documents.filesize']}
    expect( flash_message ).to eq "You don't have permission to complete that action."
    expect( page.find('span#filesize').text ).to eq default_value
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
    expect( SiteConfig['corporate_services.strategic_plans.start_date'] ).to match(/^April 1/)
  end
end
