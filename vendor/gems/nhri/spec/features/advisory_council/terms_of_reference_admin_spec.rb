require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/advisory_council/terms_of_reference_admin_spec_helper'

feature "icc reference document admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include TermsOfReferenceAdminSpecHelper

  scenario "no titles configured" do
    visit nhri_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "change filesize" do
    visit nhri_admin_path('en')
    set_filesize("22")
    expect{ page.find('#terms_of_reference_version_filesize #change_filesize').click; sleep(0.2)}.
      to change{ TermsOfReferenceVersion.maximum_filesize}.to(22)
    expect( page.find('#terms_of_reference_version_filesize span#filesize').text ).to eq "22"
  end
end

feature "icc reference document filetype admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include TermsOfReferenceAdminSpecHelper

  scenario "no filetypes configured" do
    visit nhri_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "filetypes configured" do
    TermsOfReferenceVersion.permitted_filetypes=["pdf"]
    visit nhri_admin_path('en')
    expect(page.find('#terms_of_reference_version_filetypes .type').text).to eq 'pdf'
  end

  scenario "add filetype" do
    visit nhri_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
    page.find('#terms_of_reference_version_filetypes input').set('docx')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ TermsOfReferenceVersion.permitted_filetypes }.from([]).to(["docx"])
    expect(page).not_to have_selector '#empty'
    page.find('#terms_of_reference_version_filetypes input').set('ppt')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ TermsOfReferenceVersion.permitted_filetypes.length }.from(1).to(2)
  end

  scenario "add duplicate filetype" do
    TermsOfReferenceVersion.permitted_filetypes=["pdf", "doc"]
    visit nhri_admin_path('en')
    sleep(0.1)
    page.find('#terms_of_reference_version_filetypes input').set('doc')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ TermsOfReferenceVersion.permitted_filetypes }
    expect( flash_message ).to eq "Filetype already exists, must be unique."
  end

  scenario "add duplicate filetype" do
    visit nhri_admin_path('en')
    sleep(0.1)
    page.find('#terms_of_reference_version_filetypes input').set('a_very_long_filename')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ TermsOfReferenceVersion.permitted_filetypes }
    expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
  end

  scenario "delete a filetype" do
    TermsOfReferenceVersion.permitted_filetypes=["pdf", "ppt"]
    visit nhri_admin_path('en')
    delete_filetype("pdf")
    sleep(0.2)
    expect( TermsOfReferenceVersion.permitted_filetypes ).to eq ["ppt"]
    delete_filetype("ppt")
    sleep(0.2)
    expect( TermsOfReferenceVersion.permitted_filetypes ).to eq []
    expect(page).to have_selector '#empty'
  end

  scenario "change filesize" do
    visit nhri_admin_path('en')
    set_filesize("22")
    expect{ page.find('#terms_of_reference_version_filesize #change_filesize').click; sleep(0.2)}.
      to change{ TermsOfReferenceVersion.maximum_filesize}.to(22)
    expect( page.find('#terms_of_reference_version_filesize span#filesize').text ).to eq "22"
  end
end
