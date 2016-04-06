require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require 'active_support/number_helper'
require_relative '../helpers/internal_documents_spec_helpers'
require_relative '../helpers/internal_documents_default_settings'

feature "internal document management", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  #extend ActiveSupport::NumberHelper
  include InternalDocumentsSpecHelpers
  include InternalDocumentDefaultSettings

  before do
    SiteConfig['corporate_services.internal_documents.filetypes'] = ['pdf']
    SiteConfig['corporate_services.internal_documents.filesize'] = 3
    @doc = create_a_document(:revision => "3.0", :title => "my important document")
    @archive_doc = create_a_document_in_the_same_group(:title => 'first archive document', :revision => '2.9')
    visit good_governance_internal_documents_path('en')
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
    expect{upload_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.from(2).to(3)
    expect(page).to have_css(".files .template-download", :count => 2)
    doc = GoodGovernance::InternalDocument.last
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

  #scenario "add two new docs in the same upload" do
  #expect(1).to equal(2)
  #end

  scenario "add a new document but omit document name" do
    expect(page_heading).to eq "Internal Documents"
    page.attach_file("primary_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("")
    expect{upload_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}
    expect(page).to have_css(".title", :text => 'first_upload_file')
  end

  scenario "start upload before any docs have been selected" do
    expect(page_heading).to eq "Internal Documents"
    upload_files_link.click
    expect(flash_message).to eq "You must first click \"Add files...\" and select file(s) to upload"
  end

  scenario "upload an unpermitted file type" do
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('.error', :text => "File type not allowed")
    expect{ upload_files_link.click; sleep(0.5)}.not_to change{GoodGovernance::InternalDocument.count}
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
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find(".template-upload i.cancel").click
    page.attach_file("replace_file", upload_document, :visible => false)
    expect(page).to have_selector('.template-upload')
  end

  scenario "upload a file that exceeds size limit" do
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).to have_css('.error', :text => "File is too large")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "filesize threshold increased by user config" do
    SiteConfig['corporate_services.internal_documents.filesize'] = 8
    visit good_governance_internal_documents_path('en')
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).not_to have_css('.error', :text => "File is too large")
    page.find(".template-upload i.cancel").click
    expect(page).not_to have_css(".files .template_upload")
  end

  scenario "delete a file from database" do
    page.find('.template-download .delete').click
    sleep(0.3)
    expect(GoodGovernance::InternalDocument.count).to eq 1
  end

  scenario "delete the last file in a document group" do
    page.find('.template-download .delete').click
    sleep(0.3)
    expect(GoodGovernance::InternalDocument.count).to eq 1
    sleep(0.3)
    page.find('.template-download .delete').click
    sleep(0.3)
    expect(GoodGovernance::InternalDocument.count).to eq 0
    expect(DocumentGroup.count).to eq 5 # the 5 icc doc groups
  end

  scenario "delete a file from filesystem" do
    expect{ page.find('.template-download .delete').click; sleep(0.3)}.to change{Dir.new(Rails.root.join('tmp', 'uploads', 'store')).entries.length}.by(-1)
  end

  scenario "view file details", :js => true do
    expect(page).to have_css(".files .template-download", :count => 1)
    expect(page).to have_css("div.icon.details")
    page.execute_script("$('div.icon.details').first().trigger('mouseenter')")
    sleep(0.2) # transition animation
    expect(page).to have_css('.fileDetails')
    expect(page.find('.popover-content .name' ).text).to         eq (@doc.original_filename)
    expect(page.find('.popover-content .size' ).text).to         match /\d+\.?\d+ KB/
    expect(page.find('.popover-content .rev' ).text).to          eq (@doc.revision)
    expect(page.find('.popover-content .lastModified' ).text).to eq (@doc.lastModifiedDate.to_date.to_s)
    expect(page.find('.popover-content .uploadedOn' ).text).to   eq (@doc.created_at.to_date.to_s)
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
    expect(page).to have_selector(".internal_document .title .edit.in #title_error", :text => "Title cannot be blank")
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
    expect(page).to have_selector(".internal_document .revision .edit.in #revision_error", :text => "Invalid")
    click_edit_cancel_icon(page)
    expect(page.find('td.title .no_edit').text).to eq "my important document"
    expect(page.find('td.revision .no_edit').text).to eq "3.0"
  end

  scenario "edit archive doc title to icc value" do
    click_the_archive_icon
    within archive_panel do
      # the page element is now contextualized within the archive panel
      click_the_edit_icon(page)
      page.find('.template-download input.title').set("Statement of Compliance")
      page.find('.template-download input.revision').set("0.1")
      expect{ click_edit_save_icon(page); sleep(0.5) }.not_to change{ @doc.reload.title }
    end
    #expect{ click_edit_save_icon(page) }.
      #not_to change{ @doc.reload.title }
    expect(page).to have_selector(".internal_document .title .edit.in #icc_title_error", :text => "ICC accreditation file title not allowed")
    click_edit_cancel_icon(page)
    expect(page.find('.collapse .internal_document .title .no_edit').text).to eq "first archive document"
    expect(page.find('.collapse .internal_document .revision .no_edit').text).to eq "2.9"
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
    context "including user configured title" do
      before do
        expect(page_heading).to eq "Internal Documents"
        page.attach_file("replace_file", upload_document, :visible => false)
        page.find("#internal_document_title").set("some replacement file name")
        page.find('#internal_document_revision').set("3.5")
      end

      scenario "using the single-upload icon" do
        expect{upload_replace_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(1)
        expect(page.all('.template-download').count).to eq 1
        expect(page.find('.template-download .internal_document .title .no_edit span').text).to eq "some replacement file name"
        expect(page.find('.template-download .internal_document .revision .no_edit span').text).to eq "3.5"
      end

      scenario "using the buttonbar upload icon" do
        expect{upload_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(1)
        expect(page.all('.template-download').count).to eq 1
        expect(page.find('.template-download .internal_document .title .no_edit span').text).to eq "some replacement file name"
        expect(page.find('.template-download .internal_document .revision .no_edit span').text).to eq "3.5"
      end
    end

    context "omitting user configured title and revision" do
      before do
        expect(page_heading).to eq "Internal Documents"
        page.attach_file("replace_file", upload_document, :visible => false)
      end

      scenario "using the buttonbar upload icon" do
        expect{upload_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(1)
        expect(page.all('.template-download').count).to eq 1
        expect(page.find('.template-download .internal_document .title .no_edit span').text).to eq "first_upload_file"
        expect(page.find('.template-download .internal_document .revision .no_edit span').text).to eq "3.1" # previous was 3.0
      end
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
      page.find("#internal_document_title").set("some replacement file name")
      page.find('#internal_document_revision').set("3.5")
      # problem is that the add callback is being called on the first, primary file, upload input,
      # so that the uploaded file is designated as a primary file
      expect{ page.find('.template-upload .start .fa-cloud-upload').click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}
      #page.save_screenshot(Rails.root.join('tmp','screenshots','test.png'))
      expect(page.all('.template-download').count).to eq 2
    end
  end

  scenario "initiate adding a revision but cancel" do
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("some replacement file name")
    page.find('#internal_document_revision').set("3.5")
    expect(page).to have_selector('.template-upload', :visible => true)
    click_cancel_icon
    expect(page).not_to have_selector('.template-upload', :visible => true)
  end

  xscenario "ensure all functions in download-template work for newly added docs and edited docs" do

  end

  scenario "upload a revision then edit the title and revision" do
    expect(page_heading).to eq "Internal Documents"
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("some replacement file name")
    page.find('#internal_document_revision').set("3.5")
    expect{upload_replace_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(1)
    expect(page.all('.template-download').count).to eq 1
    click_the_edit_icon(page)
    page.find('.template-download input.title').set("changed my mind title")
    page.find('.template-download input.revision').set("9.9")
    expect{ click_edit_save_icon(page); sleep(0.5)}.not_to change{GoodGovernance::InternalDocument.count}
    expect(page.all('.template-download').count).to eq 1
  end

  scenario "upload a revision then edit the title and revision of the archive file" do
    expect(page_heading).to eq "Internal Documents"
    # upload the revision
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("some replacement file name")
    # make sure it worked
    page.find('#internal_document_revision').set("3.5")
    expect{upload_replace_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(1)
    expect(page.all('.template-download').count).to eq 1
    click_the_archive_icon
    within archive_panel do
      # the page element is now contextualized within the archive panel
      click_the_edit_icon(page)
      page.find('.template-download input.title').set("changed my mind title")
      page.find('.template-download input.revision').set("0.1")
      expect{ click_edit_save_icon(page); sleep(0.5)}.not_to change{GoodGovernance::InternalDocument.count}
    end
    expect(page.find('.template-download')).to have_selector('.panel-body', :visible => true)
    expect(page.find('.template-download .panel-body')).to have_selector('h4', :text => 'Archive')
    expect(page.find('.template-download .panel-body')).to have_selector('table.internal_document')
    expect(page.find('.template-download .panel-body')).to have_selector('table.internal_document .title .no_edit', :text => "changed my mind title")
    expect(page.find('.template-download .panel-body')).to have_selector('table.internal_document .revision .no_edit', :text => "0.1")
    expect(page.all('.template-download').count).to eq 1
  end

  scenario "edit an archive file to higher revision than primary" do
    visit good_governance_internal_documents_path('en')
    click_the_archive_icon
    within archive_panel do
      # the page element is now contextualized within the archive panel
      click_the_edit_icon(page)
      page.find('.template-download input.title').set("changed my mind title")
      page.find('.template-download input.revision').set("9.9")
      expect{ click_edit_save_icon(page); sleep(0.5)}.not_to change{GoodGovernance::InternalDocument.count}
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
    visit good_governance_internal_documents_path('en')
    click_the_archive_icon
    expect{ click_the_archive_delete_icon; sleep(0.2) }.to change{ GoodGovernance::InternalDocument.count }.by -1
    expect( archive_panel ).to have_selector("p", :text => 'empty')
  end

  scenario "view archive file details" do
    visit good_governance_internal_documents_path('en')
    click_the_archive_icon
    page.execute_script("$('div.icon.details').last().trigger('mouseenter')")
    expect(page).to have_css('.fileDetails')
    expect(page.find('.popover-content .name' ).text).to         eq (@archive_doc.original_filename)
    expect(page.find('.popover-content .size' ).text).to         match /\d\d(\.\d)? KB/
    expect(page.find('.popover-content .rev' ).text).to          eq (@archive_doc.revision)
    expect(page.find('.popover-content .lastModified' ).text).to eq (@archive_doc.lastModifiedDate.to_date.to_s)
    expect(page.find('.popover-content .uploadedOn' ).text).to   eq (@archive_doc.created_at.to_date.to_s)
    expect(page.find('.popover-content .uploadedBy' ).text).to   eq (@archive_doc.uploaded_by.first_last_name)
    page.execute_script("$('div.icon.details').last().trigger('mouseout')")
    expect(page).not_to have_css('.fileDetails')
  end

  describe "add multiple primary files" do
    before do
      expect(page_heading).to eq "Internal Documents"
      # first doc
      attach_file("primary_file", upload_document, :first_time)
      page.find("#internal_document_title").set("fancy file")
      page.find('#internal_document_revision').set("4.3")
      # second doc
      attach_file("primary_file", upload_document)
      page.all("#internal_document_title")[0].set("kook file") # forms are prepended, so it's first in the array
      page.all('#internal_document_revision')[0].set("5.3")
      # third doc
      attach_file("primary_file", upload_document)
      page.all("#internal_document_title")[0].set("ugly file")
      page.all('#internal_document_revision')[0].set("6.3")
    end

    scenario "upload with buttonbar action" do
      expect{upload_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(3)
      persisted_titles = GoodGovernance::InternalDocument.all.map(&:title)
      expect(persisted_titles).to include("fancy file")
      expect(persisted_titles).to include("kook file")
      expect(persisted_titles).to include("ugly file")
      expect(page).to have_css(".files .template-download .title .no_edit span", :count => 4)
      expect(page).to have_css(".files .template-download .title .no_edit span", :text => "fancy file", :count => 1)
      expect(page).to have_css(".files .template-download .title .no_edit span", :text => "kook file", :count => 1)
      expect(page).to have_css(".files .template-download .title .no_edit span", :text => "ugly file", :count => 1)
    end

    scenario "upload with multiple individual actions" do
      expect{ upload_single_file_link_click(:first) ; sleep(0.4) }.to change{ GoodGovernance::InternalDocument.count }.by(1)
      expect{ upload_single_file_link_click(:second); sleep(0.4) }.to change{ GoodGovernance::InternalDocument.count }.by(1)
      expect{ upload_single_file_link_click(:third) ; sleep(0.4) }.to change{ GoodGovernance::InternalDocument.count }.by(1)
    end
  end

  scenario "delete primary file while archive files remain" do
    create_a_document_in_the_same_group(:revision => "1.0") # now there are revs 3,2.9,1 in the db
    visit good_governance_internal_documents_path('en')
    expect(page_heading).to eq "Internal Documents"
    click_the_archive_icon
    page.find('.panel-heading .delete').click # that's the primary file
    sleep(0.2) # ajax, javascript
    # the previous highest rev archive file becomes primary:
    expect(page.find('.panel-heading td.revision .no_edit').text).to eq "2.9"
    # the previous lowest rev archive file remains in the archive
    expect(page.find('.panel-collapse td.revision .no_edit').text).to eq "1.0"
    expect(DocumentGroup.first.primary.revision).to eq "2.9"
    # confirm that the archive accordion is opened after the deletion
    expect(page.find('.template-download')).to have_selector('.panel-body', :visible => true)
    expect(page.find('.template-download .panel-body')).to have_selector('h4', :text => 'Archive')
    expect(page.find('.template-download .panel-body')).to have_selector('table.internal_document')
    # now make sure the new primary replace_file works
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("some replacement file name")
    page.find('#internal_document_revision').set("3.5")
    expect{upload_replace_files_link.click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.from(2).to(3)
    expect(page.all('.template-download').count).to eq 1
  end

  scenario "view archives" do
    create_a_document_in_the_same_group(:revision => "2.0")
    visit good_governance_internal_documents_path('en')
    expect(page_heading).to eq "Internal Documents"
    click_the_archive_icon
    expect(page.find('.template-download')).to have_selector('.panel-body', :visible => true)
    expect(page.find('.template-download .panel-body')).to have_selector('h4', :text => 'Archive')
    expect(page.find('.template-download .panel-body')).to have_selector('table.internal_document')
  end
end

feature "behaviour with multiple primary files on the page", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend ActiveSupport::NumberHelper
  include InternalDocumentsSpecHelpers
  include InternalDocumentDefaultSettings

  before do
    SiteConfig['corporate_services.internal_documents.filetypes'] = ['pdf']
    SiteConfig['corporate_services.internal_documents.filesize'] = 3
    create_a_document(:revision => "3.0", :title => "my important document")
    create_a_document(:revision => "3.0", :title => "another important document")
    visit good_governance_internal_documents_path('en')
    page.find('.template-download:nth-of-type(2) .internal_document #archive_fileinput').set(upload_document)
    page.all("#internal_document_title")[0].set("first replacement file name")
    page.all('#internal_document_revision')[0].set("3.5")
    page.find('.template-download:nth-of-type(1) .internal_document #archive_fileinput').set(upload_document)
    page.all("#internal_document_title")[0].set("second replacement file name") # the newly added field is first
    page.all('#internal_document_revision')[0].set("3.5")
  end # /before

  it "add multiple revisions to different primary files" do
    expect{upload_files_link.click; sleep(1.0)}.to change{GoodGovernance::InternalDocument.count}.from(2).to(4)
    expect(page.all('.template-download').count).to eq 2
    sleep(3.5)
    expect(page.all('.template-download .internal_document .title .no_edit span').map(&:text)).to include "first replacement file name"
    expect(page.all('.template-download .internal_document .title .no_edit span').map(&:text)).to include "second replacement file name"
    #expect(page.all('.template-download .internal_document .title .no_edit span')[0].text).to eq "first replacement file name"
    sleep(0.5)
    #expect(page.all('.template-download .internal_document .title .no_edit span')[1].text).to eq "second replacement file name"
  end
end # /feature

feature "internal document management when no filetypes have been configured", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  extend ActiveSupport::NumberHelper
  include InternalDocumentsSpecHelpers
  include InternalDocumentDefaultSettings

  before do
    create_a_document(:revision => "3.0", :title => "my important document")
    visit good_governance_internal_documents_path('en')
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
  include InternalDocumentsSpecHelpers
  include InternalDocumentDefaultSettings

  before do
    toggle_navigation_dropdown("Corporate Services")
    select_dropdown_menu_item("Internal documents")
  end

  xscenario "add a new document when permission is not granted" do
    # error is in ajax response, must handle it appropriately
  end
end

feature "sequential operations", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include InternalDocumentsSpecHelpers
  include InternalDocumentDefaultSettings
  before do
    populate_database
    SiteConfig['corporate_services.internal_documents.filetypes'] = ['pdf']
    SiteConfig['corporate_services.internal_documents.filesize'] = 3
    visit good_governance_internal_documents_path('en')
  end

  it "should correctly follow the sequence of operations" do # b/c there was a bug!
    expect(GoodGovernance::InternalDocument.count).to eq 5
    #delete a primary that has some archive files
    expect{page.find('.template-download .delete').click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(-1)
    click_the_archive_icon
    expect(page).to have_selector('table.internal_document.editable_container', :count => 4)
    #again delete a primary file
    expect{page.all('.template-download .delete')[0].click; sleep(0.5)}.to change{GoodGovernance::InternalDocument.count}.by(-1)
    expect(page).to have_selector('table.internal_document.editable_container', :count => 3)
    # try to upload an archive file CURRENTLY FAILS
    page.attach_file("replace_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("some replacement file name")
    page.find('#internal_document_revision').set("3.5")
  end
end
