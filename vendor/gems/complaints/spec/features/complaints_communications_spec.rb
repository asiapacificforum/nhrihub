require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__
require 'login_helpers'
require 'complaints_spec_setup_helpers'
require 'navigation_helpers'
require 'download_helpers'
require 'complaints_spec_helpers'
require 'complaints_communications_spec_helpers'
require 'upload_file_helpers'
require 'notes_spec_common_helpers'
require 'notes_behaviour'

feature "complaints communications", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers
  include ComplaintsCommunicationsSpecHelpers
  include UploadFileHelpers

  before(:context) do
    Webpacker.compile
  end

  it "should show a list of communicaitons" do
    expect(page).to have_selector('#communications_modal')
    expect(page).to have_selector('#communications_modal #communications .communication', :count=>1)
  end

  it "should add a communication" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      set_datepicker('new_communication_date',"May 19, 2016")
      choose("Email")

      # Received direction allows only one communicant
      choose("Received")
      expect(page).to have_checked_field("Received")
      expect(page).to have_css("#add_communicant_button.disabled")
      choose("Sent")
      expect(page).to have_checked_field("Sent")
      expect(page).not_to have_css("#add_communicant_button.disabled")

      # face to face deselects direction and disables direction radio boxes
      choose("Face to face")
      expect(page).to have_no_checked_field("Received")
      expect(page).to have_no_checked_field("Sent")
      expect(page).not_to have_selector("#email_address")

      choose("Email")
      choose("Sent")
      expect(page).to have_selector("#email_address")
      fill_in("email_address", :with => "norm@normco.com")

      # cannot add another until the last was filled in with a value
      expect(all('input.communicant').count).to eq 1
      add_communicant
      expect(all('input.communicant').count).to eq 1

      page.all('input.communicant')[0].set("Harry Harker")
      page.all(:css, 'input#email_address')[0].set("harry@acme.com")
      add_communicant
      page.all('input.communicant')[1].set("Harriet Harker")
      page.all(:css, 'input#email_address')[1].set("harriet@acme.com")
      add_communicant
      page.all('input.communicant')[2].set("Otto Maggio")
      page.all(:css, 'input#email_address')[2].set("otto@acme.com")

      # can remove a communicant
      remove_last_communicant
      expect(all('input.communicant').count).to eq 2

      add_communicant
      page.all('input.communicant')[2].set("Margarita Cormier")
      page.all(:css, 'input#email_address')[2].set("margarita@acme.com")

      # choose received when multiple communicants are already defined
      choose("Received")
      expect(page).to have_selector("#multiple_sender_error", :text => "Cannot receive from multiple communicants")
      expect{ save_communication }.not_to change{ Communication.count }
      choose("Sent")
      expect(page).not_to have_selector("#multiple_sender_error", :text => "Cannot receive from multiple communicants")

      fill_in("note", :with => "Some note text")
      attach_file('communication_document_file', upload_document)
      fill_in("attached_document_title", :with => "random stuff")
      expect(page).to have_selector("#communication_documents .document .filename", :text => "first_upload_file.pdf")
    end
    expect{ save_communication }.to change{ Communication.count }.by(1).
                                and change{ CommunicationDocument.count }.by(1).
                                and change{ communications.count }.by(1).
                                and change{ Communicant.count }.by(3)
    # on the server
    communication = Communication.find(Communication.maximum(:id)) # strange that this is necessary to reliably find the most recent!
    expect(communication.mode).to eq "email"
    # ActiveRecord stores the date field as Postgres "timestamp without time zone" type, with UTC being assumed
    raw_persisted_date = ActiveRecord::Base.connection.execute("select date from communications where note='Some note text'")[0]["date"]
    expect(raw_persisted_date).to eq "2016-05-19 07:00:00"
    expect(communication.date.inspect).to eq "Thu, 19 May 2016 07:00:00 UTC +00:00"
    expect(communication.direction).to eq "sent"
    expect(communication.user.first_last_name).to eq User.first.first_last_name
    expect(communication.note).to eq "Some note text"
    expect(communication.communication_documents.first.title).to eq "random stuff"
    expect(communication.communicants[0].name).to eq "Harry Harker"
    expect(communication.communicants[1].name).to eq "Harriet Harker"
    expect(communication.communicants[2].name).to eq "Margarita Cormier"

    expect(page).not_to have_selector('#new_communication')
    # on the browser
    communication = page.all('#communications .communication')[1]
    within communication do
      expect(find('.date').text).to eq "May 19, 2016"
      expect(find('.by').text).to eq User.first.first_last_name
      expect(all('.with')[0].text).to eq "Harry Harker"
      expect(all('.with')[1].text).to eq "Harriet Harker"
      expect(all('.with')[2].text).to eq "Margarita Cormier"
      expect(page).to have_selector '.fa-at'
      click_the_note_icon
    end
    expect(page).to have_selector('#single_note_modal .note_text', :text => "Some note text")
    dismiss_the_note_modal
    # ensure reverse chronological order
    expect(page.all('#communications .communication .date').map(&:text)).to eq [DateTime.now.to_date.strftime("%b %-e, %Y"),"May 19, 2016"]
  end

  it "terminates adding with modal close" do
    add_communication
    expect(page).to have_selector("#communications #new_communication")
    close_communications_modal
    open_communications_modal
    expect(page).not_to have_selector("#communications #new_communication")
  end

  it "should add a communication with multiple communicants, changing method midway" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      set_datepicker('new_communication_date',"May 19, 2016")
      choose("Email")

      page.all('input.communicant')[0].set("Harry Harker")
      page.all(:css, 'input#email_address')[0].set("harry@acme.com")

      add_communicant
      page.all('input.communicant')[1].set("Harriet Harker")
      page.all(:css, 'input#email_address')[1].set("harriet@acme.com")

      add_communicant
      page.all('input.communicant')[2].set("Otto Maggio")
      page.all(:css, 'input#email_address')[2].set("otto@acme.com")

      choose("Phone")
      # can remove a communicant
      remove_second_communicant
      expect(all('input.communicant').count).to eq 2

      remove_last_communicant
      expect(all('input.communicant').count).to eq 1

    end
  end

  it "should validate and not add invalid communication with null mode attribute" do
    add_communication
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).to have_selector('#mode .help-block', :text => 'You must select a method')
    within new_communication do
      choose("Email")
      expect(page).not_to have_selector('#mode .help-block', :text => 'You must select a method')
    end
  end

  it "should validate and not add invalid communication with valid mode attribute" do
    add_communication
    within new_communication do
      choose("Email")
    end
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).to have_selector('#sent_or_received .help-block', :text => 'You must select sent or received')
    within new_communication do
      choose("Received")
      expect(page).not_to have_selector('#sent_or_received .help-block', :text => 'You must select sent or received')
    end
  end

  it "should show validation errors when adding, and remove them when user enters valid information" do
    add_communication
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).not_to have_selector('#sent_or_received .help-block', :text => 'You must select sent or received')
    expect(page).to have_selector('#mode .help-block', :text => 'You must select a method')
    within new_communication do
      choose("Email")
      expect(page).not_to have_selector('#mode .help-block', :text => 'You must select a method')
      choose("Received")
      expect(page).not_to have_selector('#sent_or_received .help-block', :text => 'You must select sent or received')
    end
  end

  it "should validate and not save with blank communicant field" do
    add_communication
    within new_communication do
      choose("Email")
      choose("Received")
      fill_in("email_address", :with => "norm@normco.com")
    end
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).to have_selector('.name_error', :text => "Name can't be blank")
    page.all('input.communicant')[0].set("Harry Harker")
    expect(page).not_to have_selector('.name_error', :text => "Name can't be blank")
  end

  it "should validate and not save with blank email field" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      choose("Email")
      choose("Received")
      expect(page).to have_selector("#email_address")
    end
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).to have_selector('.email_error', :text => "Email can't be blank")
    fill_in("email_address", :with => "norm@normco.com")
    expect(page).not_to have_selector('.email_error', :text => "Email can't be blank")
  end

  it "should validate and not save with blank phone field" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      choose("Phone")
      choose("Received")
      expect(page).to have_selector("#phone")
    end
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).to have_selector('.phone_error', :text => "Phone number can't be blank")
    page.find(:css, "#new_communication input#phone").set("555-1212")
    expect(page).not_to have_selector('.phone_error', :text => "Phone number can't be blank")
  end

  it "should validate and not save with blank address field" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      choose("Letter")
      choose("Received")
      expect(page).to have_selector("#address")
    end
    expect{ save_communication }.not_to change{ Communication.count }
    expect(page).to have_selector('.address_error', :text => "Address can't be blank")
    page.find(:css, "#new_communication input#address").set("some place somewhere")
    expect(page).not_to have_selector('.address_error', :text => "Address can't be blank")
  end

  it "should reset the form if adding is cancelled" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      choose("Email")
      set_datepicker('new_communication_date',"2016, May 19")
      choose("Received")
      fill_in("note", :with => "Some note text")
      attach_file('communication_document_file', upload_document)
      fill_in("attached_document_title", :with => "random stuff")
      expect(page).to have_selector("#communication_documents .document .filename", :text => "first_upload_file.pdf")
    end
    cancel_add
    add_communication
    expect(page).to have_selector('#new_communication')
    expect(page.find('#new_communication_date').value).to eq DateTime.now.to_date.strftime("%b %-e, %Y")
    expect(page).not_to have_checked_field('#email_mode')
    expect(page).not_to have_checked_field('#phone_mode')
    expect(page).not_to have_checked_field('#letter_mode')
    expect(page).not_to have_checked_field('#face_to_face_mode')
    expect(page).not_to have_checked_field('#sent')
    expect(page).not_to have_checked_field('#received')
  end

  it "should delete a communication" do
    expect{ delete_communication; confirm_deletion; wait_for_ajax }.to change{ Communication.count }.from(1).to(0).
                                  and change{ communications.count }.from(1).to(0)
  end

end

feature "communications files", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers
  include ComplaintsCommunicationsSpecHelpers
  include UploadFileHelpers
  include DownloadHelpers

  before(:context) do
    Webpacker.compile
  end

  it "should validate file size when adding" do
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      attach_file('communication_document_file', big_upload_document)
      expect(page).to have_css('#filesize_error', :text => "File is too large")
    end
  end

  it "should validate file type when adding" do
    SiteConfig["communication_document.filetypes"] = ["pdf"]
    visit complaints_path('en')
    open_communications_modal
    add_communication
    expect(page).to have_selector('#new_communication')
    within new_communication do
      attach_file('communication_document_file', upload_image)
      expect(page).to have_css('#original_type_error', :text => "File type not allowed")
    end
  end

  it "should download files", :driver => :chrome do
    open_documents_modal
    filename = CommunicationDocument.first.filename
    expect(page).to have_selector('.communication_document_document .filename', :text=>filename)
    download_document
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    end
    expect(downloaded_file).to eq filename
  end
end
