require 'login_helpers'
require_relative './advisory_council/terms_of_reference_admin_spec_helper'

RSpec.shared_examples "file admin" do |parameter|
  include LoggedInEnAdminUserHelper # sets up logged in admin user

  feature "icc reference document admin", :js => true do

    scenario "no titles configured" do
      visit admin_page
      sleep(0.1)
      expect(page).to have_selector '#empty'
    end

    scenario "change filesize" do
      visit admin_page
      set_filesize("22")
      expect{ page.find(filesize_selector).find('#change_filesize').click; sleep(0.2)}.
        to change{ model.maximum_filesize}.to(22)
      expect( page.find(filesize_selector).find('span#filesize').text ).to eq "22"
    end
  end

  feature "icc reference document filetype admin", :js => true do

    scenario "no filetypes configured" do
      visit admin_page
      sleep(0.1)
      expect(page).to have_selector '#empty'
    end

    scenario "filetypes configured" do
      model.permitted_filetypes=["pdf"]
      visit admin_page
      expect(page.find(filetypes_selector).find('.type').text).to eq 'pdf'
    end

    scenario "add filetype" do
      visit admin_page
      sleep(0.1)
      expect(page).to have_selector '#empty'
      page.find(filetypes_selector).find('input').set('docx')
      expect{ new_filetype_button.click; sleep(0.2) }.to change{ model.permitted_filetypes }.from([]).to(["docx"])
      expect(page).not_to have_selector '#empty'
      page.find(filetypes_selector).find('input').set('ppt')
      expect{ new_filetype_button.click; sleep(0.2) }.to change{ model.permitted_filetypes.length }.from(1).to(2)
    end

    scenario "add duplicate filetype" do
      model.permitted_filetypes=["pdf", "doc"]
      visit admin_page
      sleep(0.1)
      page.find(filetypes_selector).find('input').set('doc')
      expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ model.permitted_filetypes }
      expect( flash_message ).to eq "Filetype already exists, must be unique."
    end

    scenario "add duplicate filetype" do
      visit admin_page
      sleep(0.1)
      page.find(filetypes_selector).find('input').set('a_very_long_filename')
      expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ model.permitted_filetypes }
      expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
    end

    scenario "delete a filetype" do
      model.permitted_filetypes=["pdf", "ppt"]
      visit admin_page
      delete_filetype("pdf")
      sleep(0.2)
      expect( model.permitted_filetypes ).to eq ["ppt"]
      delete_filetype("ppt")
      sleep(0.2)
      expect( model.permitted_filetypes ).to eq []
      expect(page).to have_selector '#empty'
    end

    scenario "change filesize" do
      visit admin_page
      set_filesize("22")
      expect{ page.find(filesize_selector).find('#change_filesize').click; sleep(0.2)}.
        to change{ model.maximum_filesize}.to(22)
      expect( page.find(filesize_selector).find('span#filesize').text ).to eq "22"
    end
  end
end
