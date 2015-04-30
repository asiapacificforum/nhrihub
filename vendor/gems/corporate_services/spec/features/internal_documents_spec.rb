require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "internal document management", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Corporate Services")
    select_dropdown_menu_item("Internal documents")
  end

  scenario "add a new document" do
    expect(page_heading).to eq "Internal Documents"
    expect(page_title).to eq "Internal Documents"
    page.attach_file("file", upload_document, :visible => false)
    # not sure how this field has become visible, but it works!
    page.find("#internal_document_title").set("some file name")
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(0).to(1)
    expect(page).to have_css(".files .template-download", :count => 1)
  end

  scenario "add a new document but omit document name" do
    expect(page_heading).to eq "Internal Documents"
    page.attach_file("file", upload_document, :visible => false)
    page.find("#internal_document_title").set("")
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}
    expect(page).to have_css(".title", :text => 'first_upload_file')
  end

  scenario "start upload before any docs have been selected" do
    expect(page_heading).to eq "Internal Documents"
    upload_files_link.click
    expect(flash_message).to eq "You must first click \"Add files...\" and select file(s) to upload"
  end

  scenario "upload an unpermitted file type and cancel" do
    page.attach_file("file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "File type not allowed")
    page.find(".template-upload .cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "upload a file that exceeds size limit" do
    page.attach_file("file", big_upload_document, :visible => false)
    expect(page).to have_css('.error', :text => "File is too large")
    page.find(".template-upload .cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "delete a file from database" do
    create_a_document
    visit corporate_services_internal_documents_path('en')
    expect{ page.find('.template-download .delete').click; sleep(0.3) }.to change{InternalDocument.count}.from(1).to(0)
  end

  scenario "delete a file from filesystem" do
    create_a_document
    visit corporate_services_internal_documents_path('en')
    expect{ page.find('.template-download .delete').click; sleep(0.3)}.to change{Dir.new(Rails.root.join('tmp', 'uploads', 'store')).entries.length}.by(-1)
  end

  scenario "view file details" do
    create_a_document
    visit corporate_services_internal_documents_path('en')
    page.find('.template-download .details').click
    expect(page).to have_css('.fileDetails')
    page.find('.closepopover').click
    expect(page).not_to have_css('.fileDetails')
  end

  scenario "edit filename and revision" do
    create_a_document
    visit corporate_services_internal_documents_path('en')
    click_the_edit_icon
    page.find('.template-download input.title').set("new document title")
    page.find('.template-download input.revision').set("3.3")
    expect{
      page.find('.glyphicon-ok').click
      sleep(0.1)
    }.to change{ InternalDocument.first.title }.to("new document title").
     and change{ InternalDocument.first.revision }.to("3.3")
  end

  scenario "download a file" do
    create_a_document
    visit corporate_services_internal_documents_path('en')
    click_the_download_icon
    expect(page.response_headers['Content-Type']).to eq('application/pdf')
    expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"my_test_file.pdf\"")
  end

  xscenario "view archives" do
    
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

def click_the_download_icon
  page.find('.download').click
end

def click_the_edit_icon
  page.find('.glyphicon-edit').click
  sleep(0.1)
end

def create_a_document
  FactoryGirl.create(:internal_document)
end

def add_document_link
  page.find('.fileinput-button')
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
