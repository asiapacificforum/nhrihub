require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "internal document admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

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
    expect{ page.find("#new_filetype table button").click; sleep(0.2) }.to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }.from([]).to(["docx"])
    expect(page).not_to have_selector '#empty'
    page.find('#filetype_ext').set('ppt')
    expect{ page.find("#new_filetype table button").click; sleep(0.2) }.to change{ SiteConfig['corporate_services.internal_documents.filetypes'].length }.from(1).to(2)
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

  before do
    remove_add_delete_fileconfig_permissions
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf", "doc"]
    visit corporate_services_admin_path('en')
  end

  scenario "update filetypes" do
    page.find('#filetype_ext').set('docx')
    expect{ page.find("#new_filetype table button").click; sleep(0.2) }.
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

def set_filesize(val)
  page.find('input#filesize').set(val)
end

def delete_filetype(type)
  page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
end

def remove_add_delete_fileconfig_permissions
  ActionRole.
    joins(:action => :controller).
    where('actions.action_name' => ['create', 'destroy', 'update'],
          'controllers.controller_name' => ['corporate_services/internal_documents/filetypes','corporate_services/internal_documents/filesizes']).
    destroy_all
end
