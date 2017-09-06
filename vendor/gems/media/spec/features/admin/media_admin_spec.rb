require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/media_admin_spec_helpers'
require 'shared_behaviours/file_admin_behaviour'
require 'file_admin_common_helpers'

feature "media admin", :js => true do
  include MediaAdminSpecHelpers
  include FileAdminCommonHelpers
  it_should_behave_like 'file admin'
end

feature "media admin when user not permitted", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaAdminSpecHelpers
  include FileAdminCommonHelpers

  before do
    remove_add_delete_fileconfig_permissions
    SiteConfig['media_appearance.filetypes']=["pdf", "doc"]
    visit media_appearance_admin_path('en')
  end

  scenario "update filetypes" do
    within filetypes_context do
      page.find('#filetype_ext').set('docx')
      expect{ new_filetype_button.click; sleep(0.2) }.
        not_to change{ SiteConfig['media_appearance.filetypes'] }
      expect(page.all('.type').map(&:text)).not_to include("docx")
    end
    expect( flash_message ).to eq "Sorry but you do not have requisite privileges for this action"
  end

  scenario "delete a filetype" do
    within filetypes_context do
      expect{ delete_filetype("pdf"); sleep(0.2) }.
        not_to change{ SiteConfig['media_appearance.filetypes'] }
      expect(page.all('.type').map(&:text)).to include("pdf")
    end
    expect( flash_message ).to eq "Sorry but you do not have requisite privileges for this action"
  end

  scenario "change filesize" do
    within filesize_context do
      default_value = page.find('span#filesize').text
      set_filesize("22")
      expect{ page.find('#change_filesize').click; sleep(0.2)}.
        not_to change{ SiteConfig['media_appearance.filesize']}
      expect( page.find('span#filesize').text ).to eq default_value
    end
    expect( flash_message ).to eq "Sorry but you do not have requisite privileges for this action"
  end
end
