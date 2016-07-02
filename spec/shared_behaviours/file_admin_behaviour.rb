require 'login_helpers'
require 'file_admin_common_helpers'

RSpec.shared_examples "file admin" do |parameter|
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include FileAdminCommonHelpers

  feature "document filesize admin", :js => true do
    scenario "change filesize" do
      visit admin_page
      within filesize_context do
        set_filesize("22")
        expect{ find('#change_filesize').click; wait_for_ajax}.
          to change{ model.maximum_filesize}.to(22)
        expect( find('span#filesize').text ).to eq "22"
      end
    end
  end

  feature "document filetype admin", :js => true do
    scenario "no filetypes configured" do
      visit admin_page
      within filetypes_context do
        expect(page).to have_selector "#empty"
      end
    end

    scenario "filetypes configured" do
      model.permitted_filetypes=["pdf"]
      visit admin_page
      within filetypes_context do
        expect(find('.type').text).to eq 'pdf'
      end
    end

    scenario "add filetype" do
      visit admin_page
      within filetypes_context do
        expect(page).to have_selector "#empty"
        find('input').set('docx')
        expect{ new_filetype_button.click; wait_for_ajax }.to change{ model.permitted_filetypes }.from([]).to(["docx"])
        expect(page).not_to have_selector "#empty"
        find('input').set('ppt')
        expect{ new_filetype_button.click; wait_for_ajax }.to change{ model.permitted_filetypes.length }.from(1).to(2)
      end
    end

    scenario "add duplicate filetype" do
      model.permitted_filetypes=["pdf", "doc"]
      visit admin_page
      within filetypes_context do
        find('input').set('doc')
        expect{ new_filetype_button.click; wait_for_ajax }.not_to change{ model.permitted_filetypes }
      end
      expect( flash_message ).to eq "Filetype already exists, must be unique."
    end

    scenario "add duplicate filetype" do
      visit admin_page
      within filetypes_context do
        find('input').set('a_very_long_filename')
        expect{ new_filetype_button.click; wait_for_ajax }.not_to change{ model.permitted_filetypes }
      end
      expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
    end

    scenario "delete a filetype" do
      model.permitted_filetypes=["pdf", "ppt"]
      visit admin_page
      within filetypes_context do
        delete_filetype("pdf")
        wait_for_ajax
        expect( model.permitted_filetypes ).to eq ["ppt"]
        delete_filetype("ppt")
        wait_for_ajax
        expect( model.permitted_filetypes ).to eq []
        expect(page).to have_selector "#empty"
      end
    end
  end
end
