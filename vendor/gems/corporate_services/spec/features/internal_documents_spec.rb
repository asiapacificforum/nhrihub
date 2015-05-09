require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require 'active_support/number_helper'

feature "internal document management", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend ActiveSupport::NumberHelper

  before do
    create_a_document(:revision => "3.0", :title => "my important document")
    @doc = InternalDocument.first
    visit corporate_services_internal_documents_path('en')
  end

  scenario "add a new document" do
    expect(page_heading).to eq "Internal Documents"
    expect(page_title).to eq "Internal Documents"
    expect(page.find('td.title .no_edit').text).to eq "my important document"
    expect(page.find('td.revision .no_edit').text).to eq "3.0"
    page.attach_file("primary_file", upload_document, :visible => false)
    # not sure how this field has become visible, but it works!
    page.find("#internal_document_title").set("some file name")
    page.find('#internal_document_revision').set("3.3")
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.primary.count}.from(1).to(2)
    expect(page).to have_css(".files .template-download", :count => 2)
    doc = InternalDocument.last
    expect( doc.title ).to eq "some file name"
    expect( doc.filesize ).to eq 7945
    expect( doc.original_filename ).to eq 'first_upload_file.pdf'
    expect( doc.revision_major ).to eq 3
    expect( doc.revision_minor ).to eq 3
    expect( doc.lastModifiedDate ).to eq "2015-05-04 22:37:57.000000000 +0000"
    expect( doc.document_group_id ).to eq @doc.document_group_id.succ
    expect( doc.primary ).to eq true
    expect( doc.original_type ).to eq "application/pdf"
  end

  scenario "add a new document but omit document name" do
    expect(page_heading).to eq "Internal Documents"
    page.attach_file("primary_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("")
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.primary.count}
    expect(page).to have_css(".title", :text => 'first_upload_file')
  end

  scenario "start upload before any docs have been selected" do
    expect(page_heading).to eq "Internal Documents"
    upload_files_link.click
    expect(flash_message).to eq "You must first click \"Add files...\" and select file(s) to upload"
  end

  scenario "upload an unpermitted file type and cancel" do
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "File type not allowed")
    page.find(".template-upload .cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "upload a file that exceeds size limit" do
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).to have_css('.error', :text => "File is too large")
    page.find(".template-upload .cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "delete a file from database" do
    expect{ page.find('.template-download .delete').click; sleep(0.3) }.to change{InternalDocument.primary.count}.from(1).to(0)
  end

  scenario "delete a file from filesystem" do
    expect{ page.find('.template-download .delete').click; sleep(0.3)}.to change{Dir.new(Rails.root.join('tmp', 'uploads', 'store')).entries.length}.by(-1)
  end

  scenario "view file details" do
    page.find('.template-download .details').click
    expect(page).to have_css('.fileDetails')
    expect(page.find('.popover-content .name' ).text).to         eq (@doc.original_filename)
    expect(page.find('.popover-content .size' ).text).to         match /\d\d\.\d KB/
    expect(page.find('.popover-content .rev' ).text).to          eq (@doc.revision)
    expect(page.find('.popover-content .lastModified' ).text).to eq (@doc.lastModifiedDate.to_s)
    expect(page.find('.popover-content .uploadedOn' ).text).to   eq (@doc.created_at.to_s)
    page.find('.closepopover').click
    expect(page).not_to have_css('.fileDetails')
  end

  scenario "edit filename and revision" do
    click_the_edit_icon
    page.find('.template-download input.title').set("new document title")
    page.find('.template-download input.revision').set("4.4")
    expect{
      page.find('.glyphicon-ok').click
      sleep(0.1)
    }.to change{ @doc.reload.title }.to("new document title").
     and change{ @doc.reload.revision }.to("4.4")
  end

  scenario "download a file" do
    click_the_download_icon
    expect(page.response_headers['Content-Type']).to eq('application/pdf')
    filename = @doc.original_filename
    expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
  end

  scenario "add a new revision" do
    expect(page_heading).to eq "Internal Documents"
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("some replacement file name")
    page.find('#internal_document_revision').set("3.5")
    expect{upload_replace_files_link.click; sleep(0.5)}.not_to change{InternalDocument.primary.count}
    expect(InternalDocument.archive.count).to eq 1
    expect(page.all('.template-download').count).to eq 1
  end

  # this sequence passes in all the browsers but fails in phantomjs
  xscenario "add a new file and then add a new revision to it" do
    add_a_second_file
    # attach to the second file input
    # uploading an archive file
     #page.driver.debug
    all(:file_field, "archive_fileinput")[0].set(upload_document)
    page.find("#internal_document_title").set("some replacement file name")
    page.find('#internal_document_revision').set("3.5")
    # problem is that the add callback is being called on the first, primary file, upload input,
    # so that the uploaded file is designated as a primary file
    expect{ page.find('.template-upload .start .glyphicon-upload').click; sleep(0.5)}.not_to change{InternalDocument.primary.count}
    expect(InternalDocument.archive.count).to eq 1
    #page.save_screenshot(Rails.root.join('tmp','screenshots','test.png'))
    expect(page.all('.template-download').count).to eq 2
  end

  xscenario "initiate adding a revision but cancel" do
    
  end

  xscenario "ensure all functions in download-template work for newly added docs and edited docs" do
    
  end

  scenario "delete an archive file" do
    create_a_document_in_the_same_group
    visit corporate_services_internal_documents_path('en')
    click_the_archive_icon
    expect{ click_the_archive_delete_icon; sleep(0.2) }.to change{ InternalDocument.archive.count }.by -1
    expect( archive_panel ).to have_selector("p", :text => 'empty')
  end

  scenario "view archive file details" do
    create_a_document_in_the_same_group
    visit corporate_services_internal_documents_path('en')
    click_the_archive_icon
    click_the_archive_file_details_icon
    expect(page).to have_css('.fileDetails')
    expect(page.find('.popover-content .name' ).text).to         eq (@archive_doc.original_filename)
    expect(page.find('.popover-content .size' ).text).to         match /\d\d\.\d KB/
    expect(page.find('.popover-content .rev' ).text).to          eq (@archive_doc.revision)
    expect(page.find('.popover-content .lastModified' ).text).to eq (@archive_doc.lastModifiedDate.to_s)
    expect(page.find('.popover-content .uploadedOn' ).text).to   eq (@archive_doc.created_at.to_s)
    page.find('.closepopover').click
    expect(page).not_to have_css('.fileDetails')
  end

  xscenario "add multiple archive files" do
    context "upload with buttonbar action" do
      
    end

    context "upload with multiple individual actions" do
      
    end
  end

  scenario "delete primary file while archive files remain" do
    create_a_document_in_the_same_group(:revision => "2.0")
    create_a_document_in_the_same_group(:revision => "1.0") # now there are revs 3,2,1 in the db
    visit corporate_services_internal_documents_path('en')
    expect(page_heading).to eq "Internal Documents"
    page.find('.template-download .delete').click
    sleep(0.2) # ajax, javascript
    expect(page.find('.panel-heading td.revision .no_edit').text).to eq "2.0"
    expect(page.find('.panel-collapse td.revision .no_edit').text).to eq "1.0"
    expect(InternalDocument.primary.first.revision).to eq "2.0"
    expect(page.find('.template-download')).to have_selector('.panel-body', :visible => true)
    expect(page.find('.template-download .panel-body')).to have_selector('h4', :text => 'Archive')
    expect(page.find('.template-download .panel-body')).to have_selector('table.document')
  end

  scenario "view archives" do
    create_a_document_in_the_same_group(:revision => "2.0")
    visit corporate_services_internal_documents_path('en')
    expect(page_heading).to eq "Internal Documents"
    click_the_archive_icon
    expect(page.find('.template-download')).to have_selector('.panel-body', :visible => true)
    expect(page.find('.template-download .panel-body')).to have_selector('h4', :text => 'Archive')
    expect(page.find('.template-download .panel-body')).to have_selector('table.document')
  end
end

feature "internal document management", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Corporate Services")
    select_dropdown_menu_item("Internal documents")
  end

  xscenario "add a new document when permission is not granted" do
    # error is in ajax response, must handle it appropriately
  end

end

def archive_panel
  page.find('.collapse', :text => 'Archive')
end

def click_the_archive_file_details_icon
  page.all('.details').last.click
end

def click_the_archive_delete_icon
  page.find('.collapse i.glyphicon-trash').click
end

def add_a_second_file
  page.attach_file("primary_file", upload_document, :visible => false)
  page.find("#internal_document_title").set("a second file")
  page.find('#internal_document_revision').set("3.3")
  expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.primary.count}.from(1).to(2)
  expect(page).to have_css(".files .template-download", :count => 2)
end

def click_the_archive_icon
  page.find('.template-download .fa-archive').click
  sleep(0.2)
end

def create_a_document_in_the_same_group(**options)
  revision_major, revision_minor = options.delete(:revision).split('.') if options && options[:revision]
  group_id = @doc.document_group_id
  options = options.merge({ :revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9), :document_group_id => group_id})
  @archive_doc = FactoryGirl.create(:internal_document, :archive, options)
end

def click_the_download_icon
  page.find('.download').click
end

def click_the_edit_icon
  page.find('.glyphicon-edit').click
  sleep(0.1)
end

def create_a_document(**options)
  revision_major, revision_minor = options.delete(:revision).split('.') if options && options[:revision]
  options = options.merge({:primary => true, :revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9)})
  FactoryGirl.create(:internal_document, options)
end

def add_document_link
  page.find('.fileinput-button')
end

def upload_replace_files_link
  page.find('.template-upload .start .glyphicon-upload')
end

def upload_files_link
  page.find('.fileupload-buttonbar button.start')
end

def upload_file_path(filename)
  Rails.root.join('spec','support','uploadable_files', filename)
end

def upload_document
  upload_file_path('first_upload_file.pdf')
end

def big_upload_document
  upload_file_path('big_upload_file.pdf')
end

def upload_image
  upload_file_path('first_upload_image_file.png')
end
