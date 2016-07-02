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
      find('#communication_date').set('2016, Aug 19')
      close_datepicker
      choose("Received")
      select("Hailee Ortiz", :from => "communication_by")
      fill_in("note", :with => "Some note text")
      attach_file('communication_document_file', upload_document)
      expect(page).to have_selector('#selected_file', :text => 'first_upload_file.pdf')
    end
    expect{ save_communication }.to change{ Communication.count }.by(1).
                                and change{ communications.count }.by(1)
    # on the server
    communication = Communication.last
    expect(communication.mode).to eq "email"
    expect(communication.date).to eq DateTime.new(2016,8,19,0,0,0,'-7')
    expect(communication.direction).to eq "received"
    expect(communication.user.first_last_name).to eq "Hailee Ortiz"
    expect(communication.note).to eq "Some note text"

    # on the browser
    communication = page.all('#communications .communication')[1]
    within communication do
      expect(find('.date').text).to eq "2016, Aug 19"
      expect(find('.by').text).to eq "Hailee Ortiz"
    end
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
end


feature "communications files", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers
  include UploadFileHelpers

  before do
    populate_database
    visit complaints_path('en')
    open_communications_modal
  end

  it "should add files to a communication" do
    
  end

  it "should delete files from a communication" do
    
  end

  it "should validate file size when adding" do
    
  end

  it "should validae file type when adding" do
    
  end

  it "should download files" do
    
  end
end
