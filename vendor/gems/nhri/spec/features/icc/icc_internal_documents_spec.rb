require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require 'download_helpers'
require_relative '../../helpers/icc/icc_spec_helper'
require_relative '../../helpers/icc/icc_setup_helper'


feature "show icc internal documents index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccSpecHelper
  include IccSetupHelper
  include DownloadHelpers

  before do
    setup_database # Statement of Compliance with 4 archive files
    SiteConfig['internal_documents.filetypes']=["pdf"]
    SiteConfig['internal_documents.filesize'] = 3
    visit nhri_icc_index_path(:en)
    @title = "Statement of Compliance"
  end

  scenario "shows list of required icc docs" do
    expect(page_heading).to eq "GANHRI Accreditation Internal Documents"
    expect(page_title).to eq "GANHRI Accreditation Internal Documents"
    expect(page).to have_selector ".internal_document .title", :text => @title
  end

  scenario "restrict titles for new docs" do
    page.attach_file("primary_file", upload_document, :visible => false)
    expect(page.all('.template-upload .title select#accreditation_required_doc_title option').map(&:text)).not_to include @title
  end

  scenario "download a file", :driver => :chrome do
    @doc = InternalDocument.all.find(&:document_group_primary?)
    click_the_download_icon
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported
      expect(page.response_headers['Content-Type']).to eq('docx')
      filename = @doc.original_filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    end
    expect(downloaded_file).to eq @doc.original_filename
  end

  scenario "download an archive file", :driver => :chrome do
    @doc = InternalDocument.all.find(&:document_group_primary?).archive_files.last
    click_the_archive_icon
    within archive_panel do
      click_the_first_download_icon
    end
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      filename = @doc.original_filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    end
    expect(downloaded_file).to eq @doc.original_filename
  end
end

feature "add a document", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccSpecHelper
  include IccSetupHelper

  context "when file constraints are specified" do
    before do
      setup_database
      SiteConfig['internal_documents.filetypes']=["pdf"]
      SiteConfig['internal_documents.filesize'] = 3
      visit nhri_icc_index_path(:en)
      @title = "Statement of Compliance"
    end

    scenario "add a new document" do
      page.attach_file("primary_file", upload_document, :visible => false)
      expect(page).not_to have_selector('#unconfigured_filetypes_error', :text => "No permitted file types have been configured")
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

  context "when file types are not specified" do
    before do
      setup_database
      visit nhri_icc_index_path(:en)
      @title = "Statement of Compliance"
    end

    scenario "add a new document" do
      page.attach_file("primary_file", upload_document, :visible => false)
      expect(page).to have_selector('#unconfigured_filetypes_error', :text => "No permitted file types have been configured")
    end
  end

end

feature "delete documents", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccSpecHelper
  include IccSetupHelper

    before do
      setup_database_multiple_docs # Statement of Compliance, Annual Report and Budget
      SiteConfig['internal_documents.filetypes']=["pdf"]
      SiteConfig['internal_documents.filesize'] = 3
      visit nhri_icc_index_path(:en)
      @title = "Statement of Compliance"
    end

    scenario "delete the first document" do
      expect(page.all('.files .internal_document .title .no_edit span')[0].text).to eq "Statement of Compliance"
      expect(page.all('.files .internal_document .title .no_edit span')[1].text).to eq "Annual Report"
      expect(page.all('.files .internal_document .title .no_edit span')[2].text).to eq "Budget"
      expect{delete_first_document; confirm_deletion; wait_for_ajax}.to change{page.all('.files .internal_document').count}.from(3).to(2)
      expect(page.all('.files .internal_document .title .no_edit span')[0].text).to eq "Annual Report"
      expect(page.all('.files .internal_document .title .no_edit span')[1].text).to eq "Budget"
    end

end
