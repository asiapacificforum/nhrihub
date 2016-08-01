require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/internal_documents_admin_spec_helpers'
require 'shared_behaviours/file_admin_behaviour'
require 'file_admin_common_helpers'

feature "internal document admin", :js => true do
  include InternalDocumentAdminSpecHelpers
  include FileAdminCommonHelpers
  it_should_behave_like "file admin"
end

feature "internal document admin when user not permitted", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include InternalDocumentAdminSpecHelpers
  include FileAdminCommonHelpers

  before do
    remove_add_delete_fileconfig_permissions
    SiteConfig['internal_documents.filetypes']=["pdf", "doc"]
    visit admin_page
  end

  scenario "update filetypes" do
    within filetypes_context do
      page.find('#filetype_ext').set('docx')
      expect{ new_filetype_button.click; sleep(0.2) }.
        not_to change{ SiteConfig['internal_documents.filetypes'] }
      expect(page.all('.type').map(&:text)).not_to include("docx")
    end
    expect( flash_message ).to eq "You don't have permission to complete that action."
  end

  scenario "delete a filetype" do
    within filetypes_context do
      expect{ delete_filetype("pdf"); sleep(0.2) }.
        not_to change{ SiteConfig['internal_documents.filetypes'] }
      expect(page.all('.type').map(&:text)).to include("pdf")
    end
    expect( flash_message ).to eq "You don't have permission to complete that action."
  end

  scenario "change filesize" do
    visit admin_page
    default_value = page.find('span#filesize').text
    within filesize_context do
      set_filesize("22")
      expect{ page.find('#change_filesize').click; sleep(0.2)}.
        not_to change{ SiteConfig['internal_documents.filesize']}
      expect( page.find('span#filesize').text ).to eq default_value
    end
    expect( flash_message ).to eq "You don't have permission to complete that action."
  end
end
