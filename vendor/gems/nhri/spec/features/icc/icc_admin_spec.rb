require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/icc/icc_admin_spec_helper'
require_relative '../../helpers/icc/icc_context_admin_spec_helper'
require 'shared_behaviours/file_admin_behaviour'

feature "icc reference document admin titles configuration", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccAdminSpecHelper

  scenario "no titles configured" do
    visit nhri_admin_path('en')
    sleep(0.1)
    within page.find('#doc_groups') do
      expect(page).to have_selector '#empty'
    end
  end

  scenario "titles configured" do
    FactoryGirl.create(:accreditation_document_group, :title => "Statement of Compliance")
    visit nhri_admin_path('en')
    within page.find('#doc_groups') do
      expect(page.find('.type').text).to eq 'Statement of Compliance'
    end
  end

  scenario "add title" do
    visit nhri_admin_path('en')
    sleep(0.1)
    within page.find('#doc_groups') do
      expect(page).to have_selector '#empty'
      page.find('#doc_group_title').set('Annual Report')
      expect{ new_doc_group_button.click; sleep(0.2) }.to change{ AccreditationDocumentGroup.count }.from(0).to(1)
      expect(page).not_to have_selector '#empty'
      page.find('#doc_group_title').set('Implementation Plan')
      expect{ new_doc_group_button.click; sleep(0.2) }.to change{ AccreditationDocumentGroup.count }.from(1).to(2)
    end
  end

  scenario "add duplicate title" do
    FactoryGirl.create(:accreditation_document_group, :title => "Statement of Compliance")
    visit nhri_admin_path('en')
    sleep(0.1)
    within page.find('#doc_groups') do
      page.find('#doc_group_title').set('Statement of Compliance')
      expect{ new_doc_group_button.click; sleep(0.2) }.not_to change{ AccreditationDocumentGroup.count }
    end
    expect( flash_message ).to eq "Title already exists, must be unique."
  end

  scenario "add blank title" do
    visit nhri_admin_path('en')
    sleep(0.1)
    within page.find('#doc_groups') do
      page.find('#doc_group_title').set('')
      expect{ new_doc_group_button.click; sleep(0.2) }.not_to change{ AccreditationDocumentGroup.count }
    end
    expect( flash_message ).to eq "Cannot be blank."
  end

  scenario "delete a title" do
    FactoryGirl.create(:accreditation_document_group, :title => "Statement of Compliance")
    FactoryGirl.create(:accreditation_document_group, :title => "Annual Report")
    visit nhri_admin_path('en')
    within page.find('#doc_groups') do
      expect{ delete_title("Statement of Compliance"); sleep(0.2) }.to change{AccreditationDocumentGroup.count}.by(-1)
      expect(AccreditationDocumentGroup.all.map(&:title).first).to eq "Annual Report"
      expect{ delete_title("Annual Report"); sleep(0.2) }.to change{AccreditationDocumentGroup.count}.to(0)
      expect(page).to have_selector '#empty'
    end
  end

end

feature "icc reference document filetype admin", :js => true do
  include IccContextAdminSpecHelper
  it_should_behave_like "file admin"
end
