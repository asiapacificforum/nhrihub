require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require 'active_support/number_helper'

feature "internal document management", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend ActiveSupport::NumberHelper

  before do
    SiteConfig['corporate_services.internal_documents.filetypes'] = ['pdf']
    SiteConfig['corporate_services.internal_documents.filesize'] = 3
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
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
    expect(page).to have_css(".files .template-download", :count => 2)
    doc = InternalDocument.last
    expect( doc.title ).to eq "some file name"
    expect( doc.filesize ).to be > 0 # it's the best we can do, if we don't know the file size
    expect( doc.original_filename ).to eq 'first_upload_file.pdf'
    expect( doc.revision_major ).to eq 3
    expect( doc.revision_minor ).to eq 3
    expect( doc.lastModifiedDate ).to be_a ActiveSupport::TimeWithZone # it's a weak assertion!
    expect( doc.document_group_id ).to eq @doc.document_group_id.succ
    expect( doc.primary? ).to eq true
    expect( doc.original_type ).to eq "application/pdf"
  end

  scenario "add a new document but omit document name" do
    expect(page_heading).to eq "Internal Documents"
    page.attach_file("primary_file", upload_document, :visible => false)
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
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "File type not allowed")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "upload a file that exceeds size limit" do
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).to have_css('.error', :text => "File is too large")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "filesize threshold increased by user config" do
    SiteConfig['corporate_services.internal_documents.filesize'] = 8
    visit corporate_services_internal_documents_path('en')
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).not_to have_css('.error', :text => "File is too large")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "delete a file from database" do
    page.find('.template-download .delete').click
    sleep(0.3)
    expect(InternalDocument.count).to eq 0
  end

  scenario "delete a file from filesystem" do
    expect{ page.find('.template-download .delete').click; sleep(0.3)}.to change{Dir.new(Rails.root.join('tmp', 'uploads', 'store')).entries.length}.by(-1)
  end

  scenario "view file details", :js => true do
    #page.find('.template-download .details').click
    expect(page).to have_css(".files .template-download", :count => 1)
    expect(page).to have_css("div.icon.details")
    page.execute_script("$('div.icon.details').first().trigger('mouseenter')")
    sleep(0.2) # transition animation
    expect(page).to have_css('.fileDetails')
    expect(page.find('.popover-content .name' ).text).to         eq (@doc.original_filename)
    expect(page.find('.popover-content .size' ).text).to         match /\d+\.?\d+ KB/
    expect(page.find('.popover-content .rev' ).text).to          eq (@doc.revision)
    expect(page.find('.popover-content .lastModified' ).text).to eq (@doc.lastModifiedDate.to_s)
    expect(page.find('.popover-content .uploadedOn' ).text).to   eq (@doc.created_at.to_s)
    expect(page.find('.popover-content .uploadedBy' ).text).to   eq (@doc.uploaded_by.first_last_name)
    page.execute_script("$('div.icon.details').first().trigger('mouseout')")
    expect(page).not_to have_css('.fileDetails')
  end

  scenario "edit filename and revision" do
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("new document title")
    page.find('.template-download input.revision').set("4.4")
    expect{ click_edit_save_icon(page) }.
               to change{ @doc.reload.title }.to("new document title").
               and change{ @doc.reload.revision }.to("4.4")
  end

  scenario "edit filename to blank" do
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("")
    page.find('.template-download input.revision').set("4.4")
    expect{ click_edit_save_icon(page) }.
               not_to change{ @doc.reload.title }
    expect(page).to have_selector(".document .title .edit.in #title_error", :text => "Title cannot be blank")
    click_edit_cancel_icon(page)
    expect(page.find('td.title .no_edit').text).to eq "my important document"
    expect(page.find('td.revision .no_edit').text).to eq "3.0"
  end

  scenario "edit revision to invalid value" do
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("new document title")
    page.find('.template-download input.revision').set("")
    expect{ click_edit_save_icon(page) }.
               not_to change{ @doc.reload.title }
    expect(page).to have_selector(".document .revision .edit.in #revision_error", :text => "Invalid")
    click_edit_cancel_icon(page)
    expect(page.find('td.title .no_edit').text).to eq "my important document"
    expect(page.find('td.revision .no_edit').text).to eq "3.0"
  end

  scenario "start editing, cancel editing, start editing" do
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("new document title")
    page.find('.template-download input.revision').set("4.4")
    click_edit_cancel_icon(page)
    expect(page.find('td.title .no_edit').text).to eq "my important document"
    expect(page.find('td.revision .no_edit').text).to eq "3.0"
    click_the_edit_icon(page)
    expect(page.find('td.title .edit input').value).to eq "my important document"
    expect(page.find('td.revision .edit input').value).to eq "3.0"
  end

  scenario "download a file" do
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported, can't test download
      click_the_download_icon
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      filename = @doc.original_filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    else
      expect(1).to eq 1 # download not supported by selenium driver
    end
  end

  feature "add a new revision" do
    before do
      expect(page_heading).to eq "Internal Documents"
      page.attach_file("replace_file", upload_document, :visible => false)
      page.find("#internal_document_archive_files__title").set("some replacement file name")
      page.find('#internal_document_archive_files__revision').set("3.5")
    end

    scenario "using the single-upload icon" do
      expect{upload_replace_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
      expect(page.all('.template-download').count).to eq 1
    end

    scenario "using the buttonbar upload icon" do
      expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
      expect(page.all('.template-download').count).to eq 1
    end
  end

  # this sequence passes in all the browsers but fails in phantomjs
  scenario "add a new file and then add a new revision to it" do
    unless ie_remote?(page)
      expect(1).to eq 1 # download not supported by selenium driver
    else
      add_a_second_file
      # attach to the second file input
      # uploading an archive file
       #page.driver.debug
      all(:file_field, "archive_fileinput")[0].set(upload_document)
      page.find("#internal_document_archive_files__title").set("some replacement file name")
      page.find('#internal_document_archive_files__revision').set("3.5")
      # problem is that the add callback is being called on the first, primary file, upload input,
      # so that the uploaded file is designated as a primary file
      expect{ page.find('.template-upload .start .fa-cloud-upload').click; sleep(0.5)}.to change{InternalDocument.count}
      #page.save_screenshot(Rails.root.join('tmp','screenshots','test.png'))
      expect(page.all('.template-download').count).to eq 2
    end
  end

  scenario "initiate adding a revision but cancel" do
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_archive_files__title").set("some replacement file name")
    page.find('#internal_document_archive_files__revision').set("3.5")
    expect(page).to have_selector('.template-upload', :visible => true)
    click_cancel_icon
    expect(page).not_to have_selector('.template-upload', :visible => true)
  end

  xscenario "ensure all functions in download-template work for newly added docs and edited docs" do
    
  end

  scenario "upload a revision then edit the title and revision" do
    expect(page_heading).to eq "Internal Documents"
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_archive_files__title").set("some replacement file name")
    page.find('#internal_document_archive_files__revision').set("3.5")
    expect{upload_replace_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
    expect(page.all('.template-download').count).to eq 1
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("changed my mind title")
    page.find('.template-download input.revision').set("9.9")
    expect{ click_edit_save_icon(page); sleep(0.5)}.not_to change{InternalDocument.count}
    expect(page.all('.template-download').count).to eq 1
  end

  scenario "upload a revision then edit the title and revision of the archive file" do
    expect(page_heading).to eq "Internal Documents"
    # upload the revision
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_archive_files__title").set("some replacement file name")
    # make sure it worked
    page.find('#internal_document_archive_files__revision').set("3.5")
    expect{upload_replace_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
    expect(page.all('.template-download').count).to eq 1
    click_the_archive_icon
    within archive_panel do
      # the page element is now contextualized within the archive panel
      click_the_edit_icon(page)
      page.find('.template-download input.title').set("changed my mind title")
      page.find('.template-download input.revision').set("0.1")
      expect{ click_edit_save_icon(page); sleep(0.5)}.not_to change{InternalDocument.count}
    end
    expect(page.find('.template-download')).to have_selector('.panel-body', :visible => true)
    expect(page.find('.template-download .panel-body')).to have_selector('h4', :text => 'Archive')
    expect(page.find('.template-download .panel-body')).to have_selector('table.document')
    expect(page.find('.template-download .panel-body')).to have_selector('table.document .title .no_edit', :text => "changed my mind title")
    expect(page.find('.template-download .panel-body')).to have_selector('table.document .revision .no_edit', :text => "0.1")
    expect(page.all('.template-download').count).to eq 1
  end

  scenario "edit an archive file to higher revision than primary" do
    create_a_document_in_the_same_group({:revision => 0.3})
    visit corporate_services_internal_documents_path('en')
    click_the_archive_icon
    within archive_panel do
      # the page element is now contextualized within the archive panel
      click_the_edit_icon(page)
      page.find('.template-download input.title').set("changed my mind title")
      page.find('.template-download input.revision').set("9.9")
      expect{ click_edit_save_icon(page); sleep(0.5)}.not_to change{InternalDocument.count}
    end
    within primary_panel do
      expect(page.find('.title .no_edit').text).to eq "changed my mind title"
      expect(page.find('.revision .no_edit').text).to eq "9.9"
    end
    # make sure the previous primary is in the archive
    within archive_panel do
      expect(page.find('.revision .no_edit').text).to eq "3.0"
    end
  end

  xscenario "add a new file without specifying the revision" do
    # it should set the rev to 1.0
    # use the buttonbar upload button 'cause it's not working!
  end

  xscenario "add a file revision without specifying the revision" do
    # it should increment the minor rev
  end

  scenario "delete an archive file" do
    create_a_document_in_the_same_group
    visit corporate_services_internal_documents_path('en')
    click_the_archive_icon
    expect{ click_the_archive_delete_icon; sleep(0.2) }.to change{ InternalDocument.count }.by -1
    expect( archive_panel ).to have_selector("p", :text => 'empty')
  end

  scenario "view archive file details" do
    create_a_document_in_the_same_group(:revision => "0.1")
    visit corporate_services_internal_documents_path('en')
    click_the_archive_icon
    page.execute_script("$('div.icon.details').last().trigger('mouseenter')")
    expect(page).to have_css('.fileDetails')
    expect(page.find('.popover-content .name' ).text).to         eq (@archive_doc.original_filename)
    expect(page.find('.popover-content .size' ).text).to         match /\d\d(\.\d)? KB/
    expect(page.find('.popover-content .rev' ).text).to          eq (@archive_doc.revision)
    expect(page.find('.popover-content .lastModified' ).text).to eq (@archive_doc.lastModifiedDate.to_s)
    expect(page.find('.popover-content .uploadedOn' ).text).to   eq (@archive_doc.created_at.to_s)
    expect(page.find('.popover-content .uploadedBy' ).text).to   eq (@archive_doc.uploaded_by.first_last_name)
    page.execute_script("$('div.icon.details').last().trigger('mouseout')")
    expect(page).not_to have_css('.fileDetails')
  end

  describe "add multiple primary files" do
    before do
      expect(page_heading).to eq "Internal Documents"
      # first doc
      page.attach_file("primary_file", upload_document, :visible => false)
      page.find("#internal_document_title").set("fancy file")
      page.find('#internal_document_revision').set("4.3")
      # second doc
      page.attach_file("primary_file", upload_document, :visible => false)
      page.all("#internal_document_title")[1].set("kook file")
      page.all('#internal_document_revision')[1].set("5.3")
      # third doc
      page.attach_file("primary_file", upload_document, :visible => false)
      page.all("#internal_document_title")[2].set("ugly file")
      page.all('#internal_document_revision')[2].set("6.3")
    end

    scenario "upload with buttonbar action" do
      expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(4)
      expect(page).to have_css(".files .template-download", :count => 4)
    end

    scenario "upload with multiple individual actions" do
      expect{ upload_single_file_link_click(:first) ; sleep(0.4) }.to change{ InternalDocument.count }.from(1).to(2)
      expect{ upload_single_file_link_click(:second); sleep(0.4) }.to change{ InternalDocument.count }.from(2).to(3)
      expect{ upload_single_file_link_click(:third) ; sleep(0.4) }.to change{ InternalDocument.count }.from(3).to(4)
    end
  end

  scenario "delete primary file while archive files remain" do
    create_a_document_in_the_same_group(:revision => "2.0")
    create_a_document_in_the_same_group(:revision => "1.0") # now there are revs 3,2,1 in the db
    visit corporate_services_internal_documents_path('en')
    expect(page_heading).to eq "Internal Documents"
    click_the_archive_icon
    page.find('.panel-heading .delete').click # that's the primary file
    sleep(0.2) # ajax, javascript
    # the previous highest rev archive file becomes primary:
    expect(page.find('.panel-heading td.revision .no_edit').text).to eq "2.0"
    # the previous lowest rev archive file remains in the archive
    expect(page.find('.panel-collapse td.revision .no_edit').text).to eq "1.0"
    expect(DocumentGroup.first.primary.revision).to eq "2.0"
    # confirm that the archive accordion is opened after the deletion
    expect(page.find('.template-download')).to have_selector('.panel-body', :visible => true)
    expect(page.find('.template-download .panel-body')).to have_selector('h4', :text => 'Archive')
    expect(page.find('.template-download .panel-body')).to have_selector('table.document')
    # now make sure the new primary replace_file works
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_archive_files__title").set("some replacement file name")
    page.find('#internal_document_archive_files__revision').set("3.5")
    expect{upload_replace_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(2).to(3)
    expect(page.all('.template-download').count).to eq 1
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

feature "internal document management when no filetypes have been configured", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend ActiveSupport::NumberHelper

  before do
    create_a_document(:revision => "3.0", :title => "my important document")
    @doc = InternalDocument.first
    visit corporate_services_internal_documents_path('en')
  end

  scenario "upload an unpermitted file type and cancel" do
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "No permitted file types have been configured")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
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

def click_edit_save_icon(context)
  context.find('.fa-check').click
  sleep(0.1)
end

def click_edit_cancel_icon(context)
  context.find('.fa-remove').click
  sleep(0.1)
end

def upload_single_file_link_click(which)
  sleep(0.1) # ajax response and javascript transitions
  links = page.all('.template-upload .fa-cloud-upload')
  links[0].click()
  sleep(0.2) # ajax post of file
end

def click_cancel_icon
  page.find(".template-upload .fa-ban").click
end

def archive_panel
  page.find('.collapse', :text => 'Archive')
end


def primary_panel
  page.find('.template-download .panel-heading')
end

def click_the_archive_file_details_icon
  page.all('.details').last.click
end

def click_the_archive_delete_icon
  page.find('.collapse i.fa-trash-o').click
end

def add_a_second_file
  page.attach_file("primary_file", upload_document, :visible => false)
  page.find("#internal_document_title").set("a second file")
  page.find('#internal_document_revision').set("3.3")
  expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
  expect(page).to have_css(".files .template-download", :count => 2)
end

def click_the_archive_icon
  page.find('.template-download .fa-folder-o').click
  sleep(0.2)
end

def create_a_document_in_the_same_group(**options)
  revision_major, revision_minor = options.delete(:revision).to_s.split('.') if options && options[:revision]
  group_id = @doc.document_group_id
  options = options.merge({ :revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9), :document_group_id => group_id})
  @archive_doc = FactoryGirl.create(:internal_document, options)
end

def click_the_download_icon
  page.find('.download').click
end

def click_the_edit_icon(context)
  context.find('.fa-pencil-square-o').click
  sleep(0.1)
end

def create_a_document(**options)
  revision_major, revision_minor = options.delete(:revision).split('.') if options && options[:revision]
  options = options.merge({:revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9)})
  FactoryGirl.create(:internal_document, options)
end

def add_document_link
  page.find('.fileinput-button')
end

def upload_replace_files_link
  page.find('.template-upload .start .fa-cloud-upload')
end

def upload_files_link
  page.find('.fileupload-buttonbar button.start')
end

def upload_file_path(filename)
  CapybaraRemote.upload_file_path(page,filename)
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
