require 'rails_helper'
require 'login_helpers'
require 'project_admin_spec_helpers'
require 'navigation_helpers'

feature "project admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ProjectAdminSpecHelpers

  scenario "no filetypes configured" do
    visit project_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "filetypes configured" do
    SiteConfig["project_document.filetypes"]=["pdf"]
    visit project_admin_path('en')
    expect(page.find('.type').text).to eq 'pdf'
  end

  scenario "add filetype" do
    visit project_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
    page.find('#filetype_ext').set('docx')
    expect{ new_filetype_button.click; wait_for_ajax }.to change{ SiteConfig["project_document.filetypes"] }.from([]).to(["docx"])
    expect(page).not_to have_selector '#empty'
    page.find('#filetype_ext').set('ppt')
    expect{ new_filetype_button.click; wait_for_ajax }.to change{ SiteConfig["project_document.filetypes"].length }.from(1).to(2)
  end

  scenario "add duplicate filetype" do
    SiteConfig["project_document.filetypes"]=["pdf", "doc"]
    visit project_admin_path('en')
    sleep(0.1)
    page.find('#filetype_ext').set('doc')
    expect{ new_filetype_button.click; wait_for_ajax }.not_to change{ SiteConfig["project_document.filetypes"] }
    expect( flash_message ).to eq "Filetype already exists, must be unique."
  end

  scenario "add duplicate filetype" do
    visit project_admin_path('en')
    sleep(0.1)
    page.find('#filetype_ext').set('a_very_long_filename')
    expect{ new_filetype_button.click; wait_for_ajax }.not_to change{ SiteConfig["project_document.filetypes"] }
    expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
  end

  scenario "delete a filetype" do
    SiteConfig["project_document.filetypes"]=["pdf", "doc"]
    visit project_admin_path('en')
    delete_filetype("pdf")
    sleep(0.2)
    expect( SiteConfig["project_document.filetypes"] ).to eq ["doc"]
    delete_filetype("doc")
    wait_for_ajax
    expect( SiteConfig["project_document.filetypes"] ).to eq []
    expect(page).to have_selector '#empty'
  end

  scenario "change filesize" do
    visit project_admin_path('en')
    set_filesize("22")
    expect{ page.find('#change_filesize').click; wait_for_ajax}.
      to change{ SiteConfig["project_document.filesize"]}.to(22)
    expect( page.find('span#filesize').text ).to eq "22"
  end
end

