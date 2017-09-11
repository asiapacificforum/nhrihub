require 'rails_helper'
require 'login_helpers'
require 'download_helpers'
require 'navigation_helpers'
require 'active_support/number_helper'
require_relative '../../helpers/icc/icc_reference_documents_spec_helpers'
require_relative '../../helpers/icc/icc_reference_documents_default_settings'

feature "list of icc reference documents", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend  ActiveSupport::NumberHelper
  include IccReferenceDocumentsSpecHelpers
  include IccReferenceDocumentDefaultSettings

  before do
    SiteConfig['nhri.icc_reference_documents.filetypes'] = ['pdf']
    SiteConfig['nhri.icc_reference_documents.filesize'] = 3
    doc = FactoryGirl.create(:icc_reference_document, :title => "my important document")
    visit nhri_icc_reference_documents_path('en')
  end

  it "should render a list of icc reference documents" do
    expect(page).to have_selector("#reference_documents .icc_reference_document", :count => 1)
  end
end

feature "icc reference document management", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend  ActiveSupport::NumberHelper
  include IccReferenceDocumentsSpecHelpers
  include IccReferenceDocumentDefaultSettings
  include DownloadHelpers

  before do
    SiteConfig['nhri.icc_reference_documents.filetypes'] = ['pdf']
    SiteConfig['nhri.icc_reference_documents.filesize'] = 3
    @doc = FactoryGirl.create(:icc_reference_document, :title => "my important document")
    visit nhri_icc_reference_documents_path('en')
  end

  scenario "add a new document" do
    expect(page_heading).to eq "GANHRI Accreditation Reference Documents"
    expect(page_title).to eq "GANHRI Accreditation Reference Documents"
    expect(page.find('div.title .no_edit').text).to eq "my important document"
    page.attach_file("primary_file", upload_document, :visible => false)
    page.find("#icc_reference_document_title").set("some file name")
    page.find("#icc_reference_document_source_url").set("http://www.example.com")
    expect{upload_files_link.click; wait_for_ajax}.to change{IccReferenceDocument.count}.from(1).to(2)
    expect(page).to have_css(".files .template-download", :count => 2)
    doc = IccReferenceDocument.last
    expect( doc.title ).to eq "some file name"
    expect( doc.filesize ).to be > 0 # it's the best we can do, if we don't know the file size
    expect( doc.original_filename ).to eq 'first_upload_file.pdf'
    expect( doc.original_type ).to eq "application/pdf"
  end

  scenario "add a new document but omit document name" do
    expect(page_heading).to eq "GANHRI Accreditation Reference Documents"
    page.attach_file("primary_file", upload_document, :visible => false)
    page.find("#icc_reference_document_title").set("")
    expect{upload_files_link.click; wait_for_ajax}.to change{IccReferenceDocument.count}
    expect(page).to have_css(".title", :text => 'first_upload_file')
  end

  scenario "start upload before any docs have been selected" do
    expect(page_heading).to eq "GANHRI Accreditation Reference Documents"
    upload_files_link.click
    expect(flash_message).to eq "You must first click \"Add files...\" and select file(s) to upload"
  end

  scenario "upload an unpermitted file type" do
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "File type not allowed")
    expect{ upload_files_link.click; wait_for_ajax}.not_to change{IccReferenceDocument.count}
  end

  scenario "upload an unpermitted file type and cancel" do
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "File type not allowed")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
    page.attach_file("primary_file", upload_document, :visible => false)
    expect(page).to have_selector('.template-upload')
  end

  scenario "upload a permitted file type, cancel, and retry with same file" do
    page.attach_file("primary_file", upload_document, :visible => false)
    page.find(".template-upload i.cancel").click
    page.attach_file("primary_file", upload_document, :visible => false)
    expect(page).to have_selector('.template-upload')
  end

  scenario "upload a file that exceeds size limit" do
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).to have_css('.error', :text => "File is too large")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "filesize threshold increased by user config" do
    IccReferenceDocument.maximum_filesize = 8
    visit nhri_icc_reference_documents_path('en')
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).not_to have_css('.error', :text => "File is too large")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "delete a file from database" do
    expect{click_delete_icon; confirm_deletion; wait_for_ajax}.to change{IccReferenceDocument.count}.to(0)
    expect(page.all('.template-download').count).to eq 0
  end

  scenario "delete a file from filesystem" do
    expect{ click_delete_icon; confirm_deletion; wait_for_ajax}.to change{uploaded_files_count}.by(-1)
  end

  scenario "view file details", :js => true do
    expect(page).to have_css(".files .template-download", :count => 1)
    expect(page).to have_css("div.icon.details")
    page.execute_script("$('div.icon.details').first().trigger('mouseenter')")
    #sleep(0.2) # transition animation
    expect(page).to have_css('.fileDetails')
    expect(page.find('.popover-content .name' ).text).to         eq (@doc.original_filename)
    expect(page.find('.popover-content .size' ).text).to         match /\d+\.?\d+ KB/
    expect(page.find('.popover-content .uploadedOn' ).text).to   eq (@doc.created_at.to_date.to_s)
    expect(page.find('.popover-content .uploadedBy' ).text).to   eq (@doc.uploaded_by.first_last_name)
    expect(page.find('.popover-content .source_url' ).text).to   eq (@doc.source_url)
    page.execute_script("$('div.icon.details').first().trigger('mouseout')")
    expect(page).not_to have_css('.fileDetails')
  end

  scenario "edit filename" do
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("new document title")
    page.find('.template-download input.source_url').set("http://www.google.com")
    expect{ click_edit_save_icon(page); wait_for_ajax }.to change{ @doc.reload.title }.to("new document title")
    expect(@doc.source_url).to eq "http://www.google.com"
    expect(page.find('.template-download .title .no_edit').text).to eq "new document title"
    expect(page.find('.template-download .source_url .no_edit').text).to eq "http://www.google.com..."
  end

  scenario "edit filename to blank" do
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("")
    expect{ click_edit_save_icon(page) }.
      not_to change{ @doc.reload.title }
    expect(page).to have_selector(".icc_reference_document .title .edit.in #title_error", :text => "Title cannot be blank")
    click_edit_cancel_icon(page)
    expect(page.find('div.title .no_edit').text).to eq "my important document"
  end

  scenario "start editing, cancel editing, start editing" do
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("new document title")
    click_edit_cancel_icon(page)
    expect(page.find('div.title .no_edit').text).to eq "my important document"
    click_the_edit_icon(page)
    expect(page.find('div.title .edit input').value).to eq "my important document"
  end

  scenario "download a file", :driver => :chrome do
    click_the_download_icon
    filename = @doc.original_filename
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    end
    expect(downloaded_file).to eq filename
  end


  describe "add multiple icc accreditation reference files" do
    before do
      expect(page_heading).to eq "GANHRI Accreditation Reference Documents"
      # first doc
      attach_file("primary_file", upload_document)
      page.find("#icc_reference_document_title").set("fancy file")
      # second doc
      attach_file("primary_file", upload_document)
      page.all("#icc_reference_document_title")[0].set("kook file") # forms are prepended, so it's first in the array
      # third doc
      attach_file("primary_file", upload_document)
      page.all("#icc_reference_document_title")[0].set("ugly file")
    end

    scenario "upload with buttonbar action" do
      expect{upload_files_link.click; wait_for_ajax}.to change{IccReferenceDocument.count}.by(3)
      persisted_titles = IccReferenceDocument.all.map(&:title)
      expect(persisted_titles).to include("fancy file")
      expect(persisted_titles).to include("kook file")
      expect(persisted_titles).to include("ugly file")
      expect(page).to have_css(".files .template-download .title .no_edit span", :count => 4)
      expect(page).to have_css(".files .template-download .title .no_edit span", :text => "fancy file", :count => 1)
      expect(page).to have_css(".files .template-download .title .no_edit span", :text => "kook file", :count => 1)
      expect(page).to have_css(".files .template-download .title .no_edit span", :text => "ugly file", :count => 1)
    end

    scenario "upload with multiple individual actions" do
      expect{ upload_single_file_link_click(:first) ; wait_for_ajax }.to change{ IccReferenceDocument.count }.by(1)
      expect{ upload_single_file_link_click(:second); wait_for_ajax }.to change{ IccReferenceDocument.count }.by(1)
      expect{ upload_single_file_link_click(:third) ; wait_for_ajax }.to change{ IccReferenceDocument.count }.by(1)
    end
  end
end

feature "reference document management when no filetypes have been configured", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend ActiveSupport::NumberHelper
  include IccReferenceDocumentsSpecHelpers
  include IccReferenceDocumentDefaultSettings

  before do
    visit nhri_icc_reference_documents_path('en')
  end

  scenario "upload an unpermitted file type and cancel" do
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "No permitted file types have been configured")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end
end

feature "open document from source_url", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend  ActiveSupport::NumberHelper
  include IccReferenceDocumentsSpecHelpers
  include IccReferenceDocumentDefaultSettings

  before do
    #@example_dot_com_server = FakeExampleDotCom.boot
    #@source_url = "http://#{@example_dot_com_server.host}:#{@example_dot_com_server.port}/something"
    @doc = FactoryGirl.create(:icc_reference_document, :title => "my important document", :source_url => example_dot_com )
    visit nhri_icc_reference_documents_path('en')
  end

  it "should open the source_url link", :driver => :chrome do
    click_the_source_url_link
    page.switch_to_window(page.windows[-1])
    page.find('h1',:text => "Example Domain") # better than sleep to await the page load
    expect(page.evaluate_script('window.location.href')).to include @doc.source_url
  end
end

feature "reference document highlighted when its id is passed in via url query string", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend  ActiveSupport::NumberHelper
  include IccReferenceDocumentsSpecHelpers
  include IccReferenceDocumentDefaultSettings

  before do
    15.times do
      FactoryGirl.create(:icc_reference_document)
    end
    icc_reference_document = FactoryGirl.create(:icc_reference_document)
    @id = icc_reference_document.id
    15.times do
      FactoryGirl.create(:icc_reference_document)
    end
    url = URI(icc_reference_document.index_url)
    visit icc_reference_document.index_url.gsub(%r{.*#{url.host}},'') # hack, don't know how else to do it, host otherwise is SITE_URL defined in lib/constants
  end

  it "should highlight the selected document" do
    expect(page).to have_selector("#reference_documents .panel-heading.highlight .icc_reference_document#icc_reference_document_editable#{@id}")
  end

  it "should scroll the selected document into view" do
    page_position = page.evaluate_script("$(document).scrollTop()")
    element_offset = page.evaluate_script("$('#icc_reference_document_editable#{@id}').offset().top")
    expect(page_position).to eq element_offset - 100
  end
end
