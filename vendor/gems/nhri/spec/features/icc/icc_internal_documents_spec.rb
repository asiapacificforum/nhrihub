require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/icc/icc_spec_helper'
require_relative '../../helpers/icc/icc_setup_helper'


feature "show icc internal documents index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccSpecHelper
  include IccSetupHelper

  before do
    setup_database
    SiteConfig['internal_documents.filetypes']=["pdf"]
    SiteConfig['internal_documents.filesize'] = 3
    visit nhri_icc_index_path(:en)
    @title = "Statement of Compliance"
  end

  scenario "shows list of required icc docs" do
    expect(page_heading).to eq "NHRI ICC Accreditation Internal Documents"
    expect(page_title).to eq "NHRI ICC Accreditation Internal Documents"
    expect(page).to have_selector ".internal_document .title", :text => @title
  end

  scenario "restrict titles for new docs" do
    page.attach_file("primary_file", upload_document, :visible => false)
    expect(page.all('.template-upload .title select#accreditation_required_doc_title option').map(&:text)).not_to include @title
  end

  scenario "add a new document" do
    page.attach_file("primary_file", upload_document, :visible => false)
    select('Budget', :from => :internal_document_title)
    expect{upload_files_link.click; wait_for_ajax}.to change{AccreditationRequiredDoc.count}.by(1)
    expect(page).to have_css(".files .template-download", :count => 2)
    doc = AccreditationRequiredDoc.unscoped.order(:created_at => :asc).last
    expect( doc.title ).to eq "Budget"
    expect( doc.filesize ).to be > 0 # it's the best we can do, if we don't know the file size
    expect( doc.original_filename ).to eq 'first_upload_file.pdf'
    expect( doc.original_type ).to eq "application/pdf"
  end

  scenario "add a document, omitting file title" do
    page.attach_file("primary_file", upload_document, :visible => false)
    expect(page).not_to have_selector('#title_error', :text => "Title cannot be blank")
    expect{upload_files_link.click; wait_for_ajax}.not_to change{InternalDocument.count}
    expect(page).to have_selector('#title_error', :text => "Title cannot be blank")
    select('Budget', :from => :internal_document_title)
    expect(page).not_to have_selector('#title_error', :text => "Title cannot be blank")
  end

end
