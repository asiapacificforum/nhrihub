require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/icc/icc_admin_spec_helper'

feature "icc reference document admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccAdminSpecHelper

  scenario "no titles configured" do
    visit nhri_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "titles configured" do
    FactoryGirl.create(:accreditation_document_group, :title => "Statement of Compliance")
    visit nhri_admin_path('en')
    expect(page.find('.doc_groups .type').text).to eq 'Statement of Compliance'
  end

  scenario "add title" do
    visit nhri_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
    page.find('#doc_group_title').set('Annual Report')
    expect{ new_doc_group_button.click; sleep(0.2) }.to change{ AccreditationDocumentGroup.count }.from(0).to(1)
    expect(page).not_to have_selector '#empty'
    page.find('#doc_group_title').set('Implementation Plan')
    expect{ new_doc_group_button.click; sleep(0.2) }.to change{ AccreditationDocumentGroup.count }.from(1).to(2)
  end

  scenario "add duplicate title" do
    FactoryGirl.create(:accreditation_document_group, :title => "Statement of Compliance")
    visit nhri_admin_path('en')
    sleep(0.1)
    page.find('#doc_group_title').set('Statement of Compliance')
    expect{ new_doc_group_button.click; sleep(0.2) }.not_to change{ AccreditationDocumentGroup.count }
    expect( flash_message ).to eq "Title already exists, must be unique."
  end

  scenario "delete a title" do
    FactoryGirl.create(:accreditation_document_group, :title => "Statement of Compliance")
    FactoryGirl.create(:accreditation_document_group, :title => "Annual Report")
    visit nhri_admin_path('en')
    expect{ delete_title("Statement of Compliance"); sleep(0.2) }.to change{AccreditationDocumentGroup.count}.by(-1)
    expect(AccreditationDocumentGroup.all.map(&:title).first).to eq "Annual Report"
    expect{ delete_title("Annual Report"); sleep(0.2) }.to change{AccreditationDocumentGroup.count}.to(0)
    expect(page).to have_selector '#empty'
  end

  scenario "change filesize" do
    visit nhri_admin_path('en')
    set_filesize("22")
    expect{ page.find('#change_filesize').click; sleep(0.2)}.
      to change{ SiteConfig['nhri.icc_reference_documents.filesize']}.to(22)
    expect( page.find('span#filesize').text ).to eq "22"
  end
end

feature "icc reference document filetype admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccAdminSpecHelper

  scenario "no filetypes configured" do
    visit nhri_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "filetypes configured" do
    SiteConfig['nhri.icc_reference_documents.filetypes']=["pdf"]
    visit nhri_admin_path('en')
    expect(page.find('.filetypes .type').text).to eq 'pdf'
  end

  scenario "add filetype" do
    visit nhri_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
    page.find('#filetype_ext').set('docx')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ SiteConfig['nhri.icc_reference_documents.filetypes'] }.from([]).to(["docx"])
    expect(page).not_to have_selector '#empty'
    page.find('#filetype_ext').set('ppt')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ SiteConfig['nhri.icc_reference_documents.filetypes'].length }.from(1).to(2)
  end

  scenario "add duplicate filetype" do
    SiteConfig['nhri.icc_reference_documents.filetypes']=["pdf", "doc"]
    visit nhri_admin_path('en')
    sleep(0.1)
    page.find('#filetype_ext').set('doc')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ SiteConfig['nhri.icc_reference_documents.filetypes'] }
    expect( flash_message ).to eq "Filetype already exists, must be unique."
  end

  scenario "add duplicate filetype" do
    visit nhri_admin_path('en')
    sleep(0.1)
    page.find('#filetype_ext').set('a_very_long_filename')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ SiteConfig['nhri.icc_reference_documents.filetypes'] }
    expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
  end

  scenario "delete a filetype" do
    SiteConfig['nhri.icc_reference_documents.filetypes']=["pdf", "ppt"]
    visit nhri_admin_path('en')
    delete_filetype("pdf")
    sleep(0.2)
    expect( SiteConfig['nhri.icc_reference_documents.filetypes'] ).to eq ["ppt"]
    delete_filetype("ppt")
    sleep(0.2)
    expect( SiteConfig['nhri.icc_reference_documents.filetypes'] ).to eq []
    expect(page).to have_selector '#empty'
  end

  scenario "change filesize" do
    visit nhri_admin_path('en')
    set_filesize("22")
    expect{ page.find('#change_filesize').click; sleep(0.2)}.
      to change{ SiteConfig['nhri.icc_reference_documents.filesize']}.to(22)
    expect( page.find('span#filesize').text ).to eq "22"
  end
end
