require 'rails_helper'
require 'login_helpers'
require 'complaints_spec_setup_helpers'
require 'navigation_helpers'
require 'complaints_spec_helpers'
require 'complaints_communications_spec_helpers'
require 'upload_file_helpers'

feature "complaints communications", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers
  include ComplaintsCommunicationsSpecHelpers
  include UploadFileHelpers

  before do
    populate_database
    visit complaints_path('en')
    # TODO this is better than the 'wait_for_model_open' and 'wait_for_modal_close' used elsewhere...
    # refactor those instances and make this available everywhere
    # or even make them automatic when visiting a page?
    # or perhaps override the bootstrap css transitions in test mode?
    page.execute_script("$('.fade').removeClass('fade')")
    open_communications_modal
  end

  it "should show a list of communicaitons" do
    expect(page).to have_selector('#communications_modal')
    expect(page).to have_selector('#communications_modal #communications .communication', :count=>1)
  end

  it "should add a communication" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      choose("Email")
      set_datepicker('new_communication_date',"2016, May 19")
      choose("Received")
      select("Hailee Ortiz", :from => "communication_by")
      fill_in("note", :with => "Some note text")
      attach_file('communication_document_file', upload_document)
      fill_in("attached_document_title", :with => "random stuff")
      expect(page).to have_selector("#communication_documents .document .filename", :text => "first_upload_file.pdf")
    end
    expect{ save_communication }.to change{ Communication.count }.by(1).
                                and change{ CommunicationDocument.count }.by(1).
                                and change{ communications.count }.by(1)
    # on the server
    communication = Communication.last
    expect(communication.mode).to eq "email"
    expect(communication.date).to eq DateTime.new(2016,5,19,0,0,0,local_offset)
    expect(communication.direction).to eq "received"
    expect(communication.user.first_last_name).to eq "Hailee Ortiz"
    expect(communication.note).to eq "Some note text"
    expect(communication.communication_documents.first.title).to eq "random stuff"

    expect(page).not_to have_selector('#new_communication')
    # on the browser
    communication = page.all('#communications .communication')[1]
    within communication do
      expect(find('.date').text).to eq "2016, May 19"
      expect(find('.by').text).to eq "Hailee Ortiz"
      expect(page).to have_selector '.fa-at'
      click_the_note_icon
    end
    expect(page).to have_selector('#single_note_modal .note_text', :text => "Some note text")
    dismiss_the_note_modal
    # ensure reverse chronological order
    expect(page.all('#communications .communication .date').map(&:text)).to eq [DateTime.now.to_date.to_s,"2016, May 19"]
  end

  it "should validate and not add invalid communication" do
    add_communication
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).to have_selector('#mode .help-block', :text => 'You must select a method')
    expect(page).to have_selector('#sent_or_received .help-block', :text => 'You must select sent or received')
    expect(page).to have_selector('#communication_by .help-block', :text => 'You must select a user')
    within new_communication do
      choose("Email")
      expect(page).not_to have_selector('#mode .help-block', :text => 'You must select a method')
      choose("Received")
      expect(page).not_to have_selector('#sent_or_received .help-block', :text => 'You must select sent or received')
      select("Hailee Ortiz", :from => "communication_by")
      expect(page).not_to have_selector('#communication_by .help-block', :text => 'You must select a user')
    end
  end

  it "should delete a communication" do
    expect{ delete_communication }.to change{ Communication.count }.from(1).to(0).
                                  and change{ communications.count }.from(1).to(0)
  end

  it "should edit a communication note" do
    edit_communication
    page.find(".note .edit textarea").set "And now for something completely different"
    expect{edit_save; wait_for_ajax}.to change{Complaint.first.communications.first.note}.to "And now for something completely different"
  end
end


feature "communications files", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers
  include ComplaintsCommunicationsSpecHelpers
  include UploadFileHelpers

  before do
    populate_database
    visit complaints_path('en')
    open_communications_modal
  end

  it "should add new files while editing" do
    edit_communication
    attach_file('communication_document_file', upload_document)
    fill_in("attached_document_title", :with => "random stuff")
    expect(page).to have_selector("#communication_documents .document .filename", :text => "first_upload_file.pdf")
    expect{edit_save; wait_for_ajax}.to change{Complaint.first.communications.first.communication_documents.count}.from(1).to(2).
                                    and change{ (`\ls tmp/uploads/store | wc -l`).to_i }.by(1)
    expect(page.find('.communication .documents .fa-file-text-o')['data-count']).to eq "2"
  end

  it "should delete persisted files from a communication while editing" do
    edit_communication
    expect{page.find('#communication_documents .communication_document_document .delete .delete_icon').click; wait_for_ajax }.
      to change{Complaint.first.communications.first.communication_documents.count}.by(-1).
     and change{ page.all('#communication_documents .communication_document_document').length }.by(-1)
    edit_cancel
    expect(page.find('.communication .documents .fa-file-text-o')['data-count']).to eq "0"
  end

  it "should deselect unpersisted files from a communication from a communication while adding" do
    edit_communication
    attach_file('communication_document_file', upload_document)
    fill_in("attached_document_title", :with => "random stuff")
    expect(page).to have_selector("#communication_documents .document .filename", :text => "first_upload_file.pdf")
    deselect_file
    expect(page).not_to have_selector("#communication_documents .document .filename", :text => "first_upload_file.pdf")
  end

  it "should validate file size when adding" do
    edit_communication
    puts "attach"
    attach_file('communication_document_file', big_upload_document)
    expect(page).to have_css('#filesize_error', :text => "File is too large")
  end

  it "should validate file type when adding" do
    expect(0).to eq 1
  end

  it "should validate file size when editing" do
    
  end

  it "should validate file type when editing" do
    
  end

  it "should download files" do
    
  end
end
