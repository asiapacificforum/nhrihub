require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__
require 'login_helpers'
require 'complaints_spec_setup_helpers'
require 'navigation_helpers'
require 'complaints_spec_helpers'
require 'upload_file_helpers'

feature "complaints index", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers
  include UploadFileHelpers

  before do
    populate_database
    visit complaints_path('en')
  end

  it "shows a list of complaints" do
    expect(page.find('h1').text).to eq "Complaints"
    expect(page).to have_selector('#complaints .complaint', :count => 1)
  end

  it "shows basic information for each complaint" do
    within first_complaint do
      expect(find('.current_assignee').text).to eq Complaint.first.assignees.first.first_last_name
      expect(find('.date_received').text).to eq Complaint.first.date_received.getlocal.to_date.to_s
      expect(all('#status_changes .status_change').first.text).to match /#{Complaint.first.status_changes.first.status_humanized}/
      expect(all('#status_changes .status_change .user_name').first.text).to match /#{Complaint.first.status_changes.first.user.first_last_name}/
      expect(all('#status_changes .status_change .date').first.text).to match /#{Complaint.first.status_changes.first.change_date.getlocal.to_date.strftime("%b %-d, %Y")}/
      expect(all('#status_changes .status_change').last.text).to match /#{Complaint.first.status_changes.last.status_humanized}/
      expect(all('#status_changes .status_change .user_name').last.text).to match /#{Complaint.first.status_changes.last.user.first_last_name}/
      expect(all('#status_changes .status_change .date').last.text).to match /#{Complaint.first.status_changes.last.change_date.getlocal.to_date.strftime("%b %-d, %Y")}/
      expect(find('.lastName').text).to eq Complaint.first.lastName
      expect(find('.firstName').text).to eq Complaint.first.firstName
    end
  end

  it "does not show status date if the date is missing" do
    Complaint.first.status_changes.last.update_attribute(:change_date, nil)
    visit complaints_path('en')
    within first_complaint do
      expect(find('.current_assignee').text).to eq Complaint.first.assignees.first.first_last_name
      status = Complaint.first.status_changes.first.status_humanized
      name =   Complaint.first.status_changes.first.user.first_last_name
      date =   Complaint.first.status_changes.first.change_date.getlocal.to_date.strftime("%b %-d, %Y")
      expect(all('#status_changes .status_change').first.text.gsub(/\s/,'')).to match "#{status} ( by #{name} , on #{date} )".gsub(/\s/,'')
      status = Complaint.first.status_changes.last.status_humanized
      name =   Complaint.first.status_changes.last.user.first_last_name
      expect(all('#status_changes .status_change').last.text.gsub(/\s/,'')).to match  "#{status} ( by #{name} )".gsub(/\s/,'')
      expect(find('.lastName').text).to eq Complaint.first.lastName
      expect(find('.firstName').text).to eq Complaint.first.firstName
    end
  end

  it "does not show attribution name if the user name is missing" do
    Complaint.first.status_changes.last.update_attribute(:user_id, nil)
    visit complaints_path('en')
    within first_complaint do
      expect(find('.current_assignee').text).to eq Complaint.first.assignees.first.first_last_name
      status = Complaint.first.status_changes.first.status_humanized
      name =   Complaint.first.status_changes.first.user.first_last_name
      date =   Complaint.first.status_changes.first.change_date.getlocal.to_date.strftime("%b %-d, %Y")
      expect(all('#status_changes .status_change').first.text.gsub(/\s/,'')).to match "#{status} ( by #{name}, on #{date} )".gsub(/\s/,'')
      status = Complaint.first.status_changes.last.status_humanized
      date =   Complaint.first.status_changes.last.change_date.getlocal.to_date.strftime("%b %-d, %Y")
      expect(all('#status_changes .status_change').last.text.gsub(/\s/,'')).to match "#{status} ( on #{date} )".gsub(/\s/,'')
      expect(find('.lastName').text).to eq Complaint.first.lastName
      expect(find('.firstName').text).to eq Complaint.first.firstName
    end
  end

  it "does not show attribution name or date if the both are missing" do
    Complaint.first.status_changes.last.update_attributes({:user_id => nil, :change_date => nil})
    visit complaints_path('en')
    within first_complaint do
      expect(find('.current_assignee').text).to eq Complaint.first.assignees.first.first_last_name
      status = Complaint.first.status_changes.last.status_humanized
      expect(all('#status_changes .status_change').last.text.gsub(/\s/,'')).to eq "#{status}".gsub(/\s/,'')
      expect(find('.lastName').text).to eq Complaint.first.lastName
      expect(find('.firstName').text).to eq Complaint.first.firstName
    end
  end

    #remove_column :complaints, :complainant
    #add_column :complaints, :firstName, :string
    #add_column :complaints, :lastName, :string
    #add_column :complaints, :chiefly_title, :string
    #add_column :complaints, :occupation, :string
    #add_column :complaints, :employer, :string
  it "expands each complaint to show additional information" do
    within first_complaint do
      expand
      expect(find('.complainant_village').text).to eq Complaint.first.village
      expect(find('.complainant_phone').text).to eq Complaint.first.phone
      expect(find('.complaint_details').text).to eq Complaint.first.details

      within assignee_history do
        Complaint.first.assigns.map(&:name).each do |name|
          expect(all('.name').map(&:text)).to include name
        end # /do
        Complaint.first.assigns.map(&:date).each do |date|
          expect(all('.date').map(&:text)).to include date
        end # /do
      end # /within

      within status_changes do
        expect(page).to have_selector('.status_change', :count => 2)
        expect(all('.status_change .user_name')[0].text).to eq User.staff.first.first_last_name
        expect(all('.status_change .user_name')[1].text).to eq User.staff.second.first_last_name
        expect(all('.status_change .date')[0].text).to eq Complaint.first.status_changes[0].created_at.localtime.to_date.to_s(:short)
        expect(all('.status_change .date')[1].text).to eq Complaint.first.status_changes[1].created_at.localtime.to_date.to_s(:short)
        expect(all('.status_change .status_humanized')[0].text).to eq "Under Evaluation"
        expect(all('.status_change .status_humanized')[1].text).to eq "Complete"
      end

      within complaint_documents do
        Complaint.first.complaint_documents.map(&:title).each do |title|
          expect(all('.complaint_document .title').map(&:text)).to include title
        end
      end

      within good_governance_complaint_bases do
        Complaint.first.good_governance_complaint_bases.map(&:name).each do |complaint_basis_name|
          expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
        end
      end

      within human_rights_complaint_bases do
        Complaint.first.human_rights_complaint_bases.map(&:name).each do |complaint_basis_name|
          expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
        end
      end

      within special_investigations_unit_complaint_bases do
        Complaint.first.special_investigations_unit_complaint_bases.map(&:name).each do |complaint_basis_name|
          expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
        end
      end

      expect(find('#mandate').text).to eq "Human Rights"

      within agencies do
        expect(all('.agency').map(&:text)).to include "SAA"
      end

    end # /within first
  end # /it

  it "adds a new complaint that is valid" do
    add_complaint
    within new_complaint do
      fill_in('lastName', :with => "Normal")
      fill_in('firstName', :with => "Norman")
      fill_in('dob', :with => "1950/08/19")
      fill_in('email', :with => "norm@acme.co.ws")
      fill_in('village', :with => "Normaltown")
      fill_in('phone', :with => "555-1212")
      fill_in('complaint_details', :with => "a long story about lots of stuff")
      fill_in('desired_outcome', :with => "Life gets better")
      choose('special_investigations_unit')
      select_male_gender
      choose('complained_to_subject_agency_yes')
      check_basis(:good_governance, "Delayed action")
      check_basis(:human_rights, "CAT")
      check_basis(:special_investigations_unit, "Unreasonable delay")
      select(User.staff.first.first_last_name, :from => "assignee")
      check_agency("SAA")
      check_agency("ACC")
      attach_file("complaint_fileinput", upload_document)
      fill_in("attached_document_title", :with => "Complaint Document")
      select_datepicker_date("#date_received",Date.today.year,Date.today.month,16)
    end
    expect(page).to have_selector("#documents .document .filename", :text => "first_upload_file.pdf")

    next_ref = Complaint.next_case_reference
    expect(new_complaint_case_reference).to eq next_ref
    expect{save_complaint.click; wait_for_ajax}.to change{ Complaint.count }.by(1)
                                               .and change{ page.all('.complaint').count }.by(1)
                                               .and change{ page.all('.new_complaint').count }.by(-1)
                                               .and change { ActionMailer::Base.deliveries.count }.by(1)
    # on the server
    complaint = Complaint.last
    expect(complaint.case_reference).to eq next_ref
    expect(complaint.lastName).to eq "Normal"
    expect(complaint.firstName).to eq "Norman"
    expect(complaint.dob).to eq Date.new(1950,8,19)
    expect(complaint.gender).to eq 'M'
    expect(complaint.email).to eq "norm@acme.co.ws"
    expect(complaint.complained_to_subject_agency).to eq true
    expect(complaint.village).to eq "Normaltown"
    expect(complaint.phone).to eq "555-1212"
    expect(complaint.details).to eq "a long story about lots of stuff"
    expect(complaint.desired_outcome).to eq "Life gets better"
    expect(complaint.mandate.key).to eq 'special_investigations_unit'
    expect(complaint.good_governance_complaint_bases.map(&:name)).to include "Delayed action"
    expect(complaint.human_rights_complaint_bases.map(&:name)).to include "CAT"
    expect(complaint.special_investigations_unit_complaint_bases.map(&:name)).to include "Unreasonable delay"
    expect(complaint.current_assignee_name).to eq User.staff.first.first_last_name
    expect(complaint.status_changes.count).to eq 1
    expect(complaint.status_changes.first.complaint_status.name).to eq "Under Evaluation"
    expect(complaint.agencies.map(&:name)).to include "SAA"
    expect(complaint.agencies.map(&:name)).to include "ACC"
    expect(complaint.complaint_documents.count).to eq 1
    expect(complaint.complaint_documents[0].filename).to eq "first_upload_file.pdf"
    expect(complaint.complaint_documents[0].title).to eq "Complaint Document"
    expect(complaint.date_received.to_date).to eq Date.new(Date.today.year, Date.today.month, 16)

    # on the client
    expect(first_complaint.find('.case_reference').text).to eq next_ref
    expect(first_complaint.find('.current_assignee').text).to eq User.staff.first.first_last_name
    expect(first_complaint.find('.lastName').text).to eq "Normal"
    expect(first_complaint.find('.firstName').text).to eq "Norman"
    expect(first_complaint.find('#status_changes .status_change .status_humanized').text).to eq 'Under Evaluation'
    expand
    expect(first_complaint.find('.complainant_dob').text).to eq "1950, Aug 19"
    expect(first_complaint.find('.email').text).to eq "norm@acme.co.ws"
    expect(first_complaint.find('.complaint_details').text).to eq "a long story about lots of stuff"
    expect(first_complaint.find('.desired_outcome').text).to eq "Life gets better"
    expect(first_complaint.find('.complainant_village').text).to eq "Normaltown"
    expect(first_complaint.find('.complainant_phone').text).to eq "555-1212"
    expect(first_complaint.find('.gender').text).to eq "male"
    expect(first_complaint.find('.complained_to_subject_agency').text).to eq "yes"
    expect(first_complaint.find('.date_received').text).to eq Date.new(Date.today.year, Date.today.month, 16).to_s

    within good_governance_complaint_bases do
      Complaint.last.good_governance_complaint_bases.map(&:name).each do |complaint_basis_name|
        expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
      end
    end

    within human_rights_complaint_bases do
      Complaint.last.human_rights_complaint_bases.map(&:name).each do |complaint_basis_name|
        expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
      end
    end

    within special_investigations_unit_complaint_bases do
      Complaint.last.special_investigations_unit_complaint_bases.map(&:name).each do |complaint_basis_name|
        expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
      end
    end

    within agencies do
      expect(all('.agency').map(&:text)).to include "SAA"
      expect(all('.agency').map(&:text)).to include "ACC"
    end

    within complaint_documents do
      expect(page.all('#complaint_documents .complaint_document')[0].find('.filename').text).to eq "first_upload_file.pdf"
      expect(page.all('#complaint_documents .complaint_document')[0].find('.title').text).to eq "Complaint Document"
    end

    expect(page.find('#mandate').text).to eq "Special Investigations Unit"
    email = ActionMailer::Base.deliveries.last
    expect( email.subject ).to eq "Notification of complaint assignment"
    lines = Nokogiri::HTML(email.body.to_s).xpath(".//p").map(&:text)
    # lin[0] is addressee
    expect( lines[0] ).to eq User.staff.first.first_last_name
    # complaint url is embedded in the email
    url = Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
    expect( url ).to match (/\/en\/complaints\.html\?case_reference=c16-1$/i)
    expect( url ).to match (/^http:\/\/#{SITE_URL}/)
  end

  it "does not add a new complaint that is invalid" do
    add_complaint
    within new_complaint do
      save_complaint.click
      expect(page).to have_selector('#firstName_error', :text => "You must enter a first name")
      expect(page).to have_selector('#lastName_error', :text => "You must enter a last name")
      expect(page).to have_selector('#village_error', :text => 'You must enter a village')
      expect(page).to have_selector('#new_assignee_id_error', :text => 'You must designate an assignee')
      expect(page).to have_selector('#mandate_name_error', :text => 'You must select an area')
      expect(page).to have_selector('#complaint_basis_id_count_error', :text => 'You must select at least one subarea')
      expect(page).to have_selector('#dob_error', :text => "You must enter the complainant's date of birth with format yyyy/mm/dd")
      expect(page).to have_selector('#details_error', :text => "You must enter the complaint details")
      fill_in('lastName', :with => "Normal")
      expect(page).not_to have_selector('#lastName_error', :text => "You must enter a first name")
      fill_in('firstName', :with => "Norman")
      expect(page).not_to have_selector('#firstName_error', :text => "You must enter a last name")
      fill_in('village', :with => "Leaden Roding")
      expect(page).not_to have_selector('#village_error', :text => 'You must enter a village')
      select(User.staff.first.first_last_name, :from => "assignee")
      expect(page).not_to have_selector('#new_assignee_id_error', :text => 'You must designate an assignee')
      choose('special_investigations_unit')
      expect(page).not_to have_selector('#mandate_name_error', :text => 'You must select an area')
      check_basis(:special_investigations_unit, "Unreasonable delay")
      expect(page).not_to have_selector('#complaint_basis_id_count_error', :text => 'You must select at least one subarea')
      fill_in('complaint_details', :with => "random text")
      expect(page).not_to have_selector('#details_error', :text => "You must enter the complaint details")
    end
  end

  it "flags as invalid when file attachment exceeds permitted filesize" do
    add_complaint

    within new_complaint do
      attach_file("complaint_fileinput", big_upload_document)
    end
    expect(page).to have_selector('#filesize_error', :text => "File is too large")

    expect{ save_complaint.click; wait_for_ajax }.not_to change{ Complaint.count }
  end

  it "flags as invalid when file attachment is unpermitted filetype" do
    SiteConfig["complaint_document.filetypes"]=["doc"]
    visit complaints_path('en')
    add_complaint

    within new_complaint do
      attach_file("complaint_fileinput", upload_image)
    end
    expect(page).to have_css('#original_type_error', :text => "File type not allowed")

    expect{ save_complaint.click; wait_for_ajax }.not_to change{ Complaint.count }
  end

  it "cancels adding" do
    add_complaint
    within new_complaint do
      fill_in('lastName', :with => "Normal")
      fill_in('firstName', :with => "Norman")
      fill_in('village', :with => "Normaltown")
      fill_in('phone', :with => "555-1212")
      choose('special_investigations_unit')
      check_basis(:good_governance, "Delayed action")
      check_basis(:human_rights, "CAT")
      check_basis(:special_investigations_unit, "Unreasonable delay")
      select(User.staff.first.first_last_name, :from => "assignee")
    end
    cancel_add
    expect(page).not_to have_selector('.new_complaint')
    add_complaint
    within new_complaint do
      expect(page.find('#lastName').value).to be_blank
      expect(page.find('#firstName').value).to be_blank
      expect(page.find('#village').value).to be_blank
      expect(page.find('#phone').value).to be_blank
      expect(basis_checkbox(:good_governance, "Delayed action")).not_to be_checked
      expect(basis_checkbox(:human_rights, "CAT")).not_to be_checked
      expect(basis_checkbox(:special_investigations_unit, "Unreasonable delay")).not_to be_checked
    end
  end

  it "changes complaint current status by adding a status_change" do
    edit_complaint
    within current_status do
      expect(page).to have_checked_field "closed"
      choose "open"
    end
    expect{ edit_save }.to change{ Complaint.first.current_status }.from("Closed").to("Open")
    expect( first_complaint.all('#status_changes .status_change').last.text ).to match "Open"
    expect( first_complaint.all('#status_changes .date').last.text ).to match /#{Date.today.to_s(:short)}/
    user = User.find_by(:login => 'admin')
    expect( first_complaint.all('#status_changes .user_name').last.text ).to match /#{user.first_last_name}/
  end

  it "edits a complaint" do
    edit_complaint
    # COMPLAINANT
    within first_complaint do
      fill_in('lastName', :with => "Normal")
      fill_in('firstName', :with => "Norman")
      fill_in('dob', :with => "1951/08/19")
      fill_in('village', :with => "Normaltown")
      fill_in('phone', :with => "555-1212")
      fill_in('complaint_details', :with => "the boy stood on the burning deck")
      fill_in('desired_outcome', :with => "Things are more better")
      choose('complained_to_subject_agency_no')
      # ASSIGNEE
      select(User.staff.last.first_last_name, :from => "assignee")
      # MANDATE
      choose('special_investigations_unit') # originally had human rights mandate
      # BASIS
      uncheck_basis(:good_governance, "Delayed action") # originally had "Delayed action" and "Failure to Act"
      uncheck_basis(:human_rights, "CAT") # originall had "CAT" "ICESCR"
      uncheck_basis(:special_investigations_unit, "Unreasonable delay") #originally had "Unreasonable delay" "Not properly investigated"
      # AGENCY
      uncheck_agency("SAA")
      check_agency("ACC")
      # DOCUMENTS
      attach_file("complaint_fileinput", upload_document)
      fill_in("attached_document_title", :with => "added complaint document")
      expect(page).to have_selector("#complaint_documents .document .filename", :text => "first_upload_file.pdf")
      select_datepicker_date("#date_received",Date.today.year,Date.today.month,23)
      # TODO can't figure out why this is necessary... it works find through the UI, but triggering via capybara needs this:
      select_datepicker_date("#date_received",Date.today.year,Date.today.month,23)
    end

    expect{ edit_save }.to change{ Complaint.first.lastName }.to("Normal").
                       and change{ Complaint.first.firstName }.to("Norman").
                       and change{ Complaint.first.village }.to("Normaltown").
                       and change{ Complaint.first.phone }.to("555-1212").
                       and change{ Complaint.first.assignees.count }.by(1).
                       and change{ Complaint.first.complaint_documents.count }.by(1).
                       and change{ (`\ls tmp/uploads/store | wc -l`).to_i }.by(1).
                       and change { ActionMailer::Base.deliveries.count }.by(1)

    expect( Complaint.first.complained_to_subject_agency ).to eq false
    expect( Complaint.first.dob ).to eq Date.new(1951,8,19)
    expect( Complaint.first.details ).to eq "the boy stood on the burning deck"
    expect( Complaint.first.desired_outcome ).to eq "Things are more better"
    expect( Complaint.first.mandate_name ).to eq "Special Investigations Unit"
    expect( Complaint.first.good_governance_complaint_bases.count ).to eq 1
    expect( Complaint.first.good_governance_complaint_bases.first.name ).to eq "Failure to act"
    expect( Complaint.first.human_rights_complaint_bases.count ).to eq 1
    expect( Complaint.first.human_rights_complaint_bases.first.name ).to eq "ICESCR"
    expect( Complaint.first.special_investigations_unit_complaint_bases.count ).to eq 1
    expect( Complaint.first.special_investigations_unit_complaint_bases.first.name ).to eq "Not properly investigated"
    expect( Complaint.first.assignees ).to include User.staff.last
    expect( Complaint.first.agencies.map(&:name) ).to include "ACC"
    expect( Complaint.first.agencies.count ).to eq 1
    expect( Complaint.first.date_received.to_date).to eq Date.new(Date.today.year, Date.today.month, 23)

    expect(page).to have_selector('.complainant_dob', :text => "1951, Aug 19")
    expect(page).to have_selector('.desired_outcome', :text => "Things are more better")
    expect(page).to have_selector('.complaint_details', :text => "the boy stood on the burning deck")
    expect(page).to have_selector('.complained_to_subject_agency', :text => "no")
    expect(page).to have_selector('.date_received',:text => Date.new(Date.today.year, Date.today.month, 23).to_s)

    within good_governance_complaint_bases do
      Complaint.last.good_governance_complaint_bases.map(&:name).each do |complaint_basis_name|
        expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
      end
    end

    within human_rights_complaint_bases do
      Complaint.last.human_rights_complaint_bases.map(&:name).each do |complaint_basis_name|
        expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
      end
    end

    within special_investigations_unit_complaint_bases do
      Complaint.last.special_investigations_unit_complaint_bases.map(&:name).each do |complaint_basis_name|
        expect(page).to have_selector('.complaint_basis', :text => complaint_basis_name)
      end
    end

    within agencies do
      expect(all('.agency').map(&:text)).to include "ACC"
    end

    within complaint_documents do
      expect(page.all('#complaint_documents .complaint_document .filename').map(&:text)).to include "first_upload_file.pdf"
      expect(page.all('#complaint_documents .complaint_document .title').map(&:text)).to include "added complaint document"
    end

    email = ActionMailer::Base.deliveries.last
    expect( email.subject ).to eq "Notification of complaint assignment"
    lines = Nokogiri::HTML(email.body.to_s).xpath(".//p").map(&:text)
    # lin[0] is addressee
    expect( lines[0] ).to eq User.staff.last.first_last_name
    # complaint url is embedded in the email
    url = Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
    expect( url ).to match (/\/en\/complaints\.html\?case_reference=#{Complaint.first.case_reference}$/)
    expect( url ).to match (/^http:\/\/#{SITE_URL}/)
  end

  it "edits a complaint with no changes to the status" do # b/c there was a bug
    edit_complaint
    expect{ edit_save }.not_to change{ Complaint.first.status_changes.count }
  end

  it "edits a complaint with no change of assignee" do
    edit_complaint
    expect{ edit_save }.to change{ Complaint.first.assignees.count }.by(0)
                       .and change { ActionMailer::Base.deliveries.count }.by(0)
  end

  it "edits a complaint, deleting a file" do
    edit_complaint
    expect{delete_document; confirm_deletion; wait_for_ajax}.to change{ Complaint.first.complaint_documents.count }.by(-1).
                                          and change{ documents.count }.by(-1)
  end

  it "should download a complaint document file" do
    expand
    @doc = ComplaintDocument.first
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported, can't test download
      click_the_download_icon
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      filename = @doc.filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    else
      expect(1).to eq 1 # download not supported by selenium driver
    end
  end

  it "restores previous values when editing is cancelled" do
    original_complaint = Complaint.first
    edit_complaint
    within first_complaint do
      fill_in('lastName', :with => "Normal")
      fill_in('firstName', :with => "Norman")
      fill_in('village', :with => "Normaltown")
      fill_in('phone', :with => "555-1212")
      check_basis(:good_governance, "Private")
      check_basis(:human_rights, "CAT")
      check_basis(:good_governance, "Contrary to Law")
      fill_in('dob', :with => "1820/11/11")
      fill_in('email', :with => "harry@haricot.net")
      select_male_gender
      fill_in('complaint_details', :with => "a long story about lots of stuff")
      fill_in('desired_outcome', :with => "bish bash bosh")
      choose('complained_to_subject_agency_yes')
      select_datepicker_date("#date_received",Date.today.year,Date.today.month,9)
      select(User.staff.last.first_last_name, :from => "assignee")
      choose('special_investigations_unit')
      check_agency("ACC")
      attach_file("complaint_fileinput", upload_document)
      fill_in("attached_document_title", :with => "some text any text")
    end
    edit_cancel
    sleep(0.5) # seems like a huge amount of time to wait for javascript, but this is what it takes for reliable operation in chrome
    edit_complaint
    within first_complaint do
      expect(page.find('#lastName').value).to eq original_complaint.lastName
      expect(page.find('#firstName').value).to eq original_complaint.firstName
      expect(page.find('#village').value).to eq original_complaint.village
      expect(page.find('#phone').value).to eq original_complaint.phone
      expect(page.all('#good_governance_bases .complaint_basis input').first['name']).to eq original_complaint.good_governance_complaint_basis_ids.join(',')
      expect(page.find('#dob').value).to eq original_complaint.dob.to_s
      expect(page.find('#email').value).to eq original_complaint.email.to_s
      expect(page.find('#m')).not_to be_checked
      expect(page.find('#complaint_details').value).to eq original_complaint.details
      expect(page.find('#desired_outcome').value).to eq original_complaint.desired_outcome.to_s
      expect(page.find('#complained_to_subject_agency_yes')).not_to be_checked
      expect(find('.date_received').text).to eq original_complaint.date_received.getlocal.to_date.to_s
      expect(find('.current_assignee').text).to eq original_complaint.assignees.first.first_last_name
      expect(page.find(".mandate ##{original_complaint.mandate.key}")).to be_checked
      expect(page.find_field("ACC")).not_to be_checked
      expect(page.find_field("SAA")).to be_checked
      expect(page).not_to have_selector("#attached_document_title")
      expect(page).not_to have_selector(".title .filename")
    end
  end

  it "resets errors if editing is cancelled" do
    edit_complaint
    # COMPLAINANT
    within first_complaint do
      fill_in('lastName', :with => "")
      fill_in('firstName', :with => "")
      fill_in('village', :with => "")
      fill_in('phone', :with => "555-1212")
      fill_in('dob', :with => "")
      fill_in('complaint_details', :with => "")
      # MANDATE
      choose('special_investigations_unit') # originally had human rights mandate
      # BASIS
      uncheck_basis(:good_governance, "Delayed action") # originally had "Delayed action" and "Failure to Act"
      uncheck_basis(:good_governance, "Failure to act") # originally had "Delayed action" and "Failure to Act"
      uncheck_basis(:human_rights, "CAT") # originall had "CAT" "ICESCR"
      uncheck_basis(:human_rights, "ICESCR") # originall had "CAT" "ICESCR"
      uncheck_basis(:special_investigations_unit, "Unreasonable delay") #originally had "Unreasonable delay" "Not properly investigated"
      uncheck_basis(:special_investigations_unit, "Not properly investigated") #originally had "Unreasonable delay" "Not properly investigated"
      # AGENCY
      uncheck_agency("SAA")
    end
    expect{ edit_save }.not_to change{ Complaint.first}

    expect(page).to have_selector('#firstName_error', :text => "You must enter a first name")
    expect(page).to have_selector('#lastName_error', :text => "You must enter a last name")
    expect(page).to have_selector('#village_error', :text => 'You must enter a village')
    expect(page).to have_selector('#complaint_basis_id_count_error', :text => 'You must select at least one subarea')
    expect(page).to have_selector('#dob_error', :text => "You must enter the complainant's date of birth with format yyyy/mm/dd")
    expect(page).to have_selector('#details_error', :text => "You must enter the complaint details")

    edit_cancel
    sleep(0.5) # seems like a huge amount of time to wait for javascript, but this is what it takes for reliable operation in chrome
    edit_complaint
    within first_complaint do
      expect(page).not_to have_selector('#firstName_error', :text => "You must enter a first name")
      expect(page).not_to have_selector('#lastName_error', :text => "You must enter a last name")
      expect(page).not_to have_selector('#village_error', :text => 'You must enter a village')
      expect(page).not_to have_selector('#mandate_name_error', :text => 'You must select an area')
      expect(page).not_to have_selector('#complaint_basis_id_count_error', :text => 'You must select at least one subarea')
      expect(page).not_to have_selector('#dob_error', :text => "You must enter the complainant's date of birth with format yyyy/mm/dd")
      expect(page).not_to have_selector('#details_error', :text => "You must enter the complaint details")
    end
  end

  it "permits only one add at a time" do
    add_complaint
    add_complaint
    expect(page.all('.new_complaint').count).to eq 1
  end

  it "permits only one edit at a time" do
    FactoryGirl.create(:complaint, :open)
    visit complaints_path('en')
    edit_first_complaint
    edit_second_complaint
    expect(page.evaluate_script("_.chain(complaints.findAllComponents('complaint')).map(function(c){return c.get('editing')}).filter(function(c){return c}).value().length")).to eq 1
  end

  it "terminates adding new complaint when editing is inititated" do
    add_complaint
    edit_first_complaint
    expect(page.all('.new_complaint').count).to eq 0
    add_complaint
    within new_complaint do
      expect(page.find('#lastName').value).to be_blank
      expect(page.find('#firstName').value).to be_blank
      expect(page.find('#village').value).to be_blank
      expect(page.find('#phone').value).to be_blank
    end
  end

  it "terminates editing complaint when adding is initiated" do
    original_complaint = Complaint.first
    edit_first_complaint
    within first_complaint do
      fill_in('lastName', :with => "Normal")
      fill_in('firstName', :with => "Norman")
      fill_in('village', :with => "Normaltown")
      fill_in('phone', :with => "555-1212")
    end
    page.execute_script("scrollTo(0,0)")
    add_complaint
    expect(page.evaluate_script("_.chain(complaints.findAllComponents('complaint')).map(function(c){return c.get('editing')}).filter(function(c){return c}).value().length")).to eq 0
    cancel_add
    sleep(0.5) # seems like a huge amount of time to wait for javascript, but this is what it takes for reliable operation in chrome
    edit_first_complaint
    within first_complaint do
      expect(page.find('#lastName').value).to eq original_complaint.lastName
      expect(page.find('#firstName').value).to eq original_complaint.firstName
      expect(page.find('#village').value).to eq original_complaint.village
      expect(page.find('#phone').value).to eq original_complaint.phone
    end
  end

  it "deletes a complaint" do
    expect{delete_complaint; confirm_deletion; wait_for_ajax}.to change{ Complaint.count }.by(-1).
                                           and change{ complaints.count }.by(-1)
  end

  it "edits a complaint to invalid values" do
    edit_complaint
    # COMPLAINANT
    within first_complaint do
      fill_in('lastName', :with => "")
      fill_in('firstName', :with => "")
      fill_in('village', :with => "")
      fill_in('phone', :with => "555-1212")
      fill_in('dob', :with => "")
      fill_in('complaint_details', :with => "")
      # MANDATE
      choose('special_investigations_unit') # originally had human rights mandate
      # BASIS
      uncheck_basis(:good_governance, "Delayed action") # originally had "Delayed action" and "Failure to Act"
      uncheck_basis(:good_governance, "Failure to act") # originally had "Delayed action" and "Failure to Act"
      uncheck_basis(:human_rights, "CAT") # originall had "CAT" "ICESCR"
      uncheck_basis(:human_rights, "ICESCR") # originall had "CAT" "ICESCR"
      uncheck_basis(:special_investigations_unit, "Unreasonable delay") #originally had "Unreasonable delay" "Not properly investigated"
      uncheck_basis(:special_investigations_unit, "Not properly investigated") #originally had "Unreasonable delay" "Not properly investigated"
      # AGENCY
      uncheck_agency("SAA")
    end
    expect{ edit_save }.not_to change{ Complaint.first}

    expect(page).to have_selector('#firstName_error', :text => "You must enter a first name")
    expect(page).to have_selector('#lastName_error', :text => "You must enter a last name")
    expect(page).to have_selector('#village_error', :text => 'You must enter a village')
    expect(page).to have_selector('#complaint_basis_id_count_error', :text => 'You must select at least one subarea')
    expect(page).to have_selector('#dob_error', :text => "You must enter the complainant's date of birth with format yyyy/mm/dd")
    expect(page).to have_selector('#details_error', :text => "You must enter the complaint details")
    within first_complaint do
      fill_in('lastName', :with => "Normal")
      expect(page).not_to have_selector('#lastName_error', :text => "You must enter a last name")
      fill_in('firstName', :with => "Norman")
      expect(page).not_to have_selector('#firstName_error', :text => "You must enter a first name")
      fill_in('village', :with => "Leaden Roding")
      expect(page).not_to have_selector('#village_error', :text => 'You must enter a village')
      choose('special_investigations_unit')
      expect(page).not_to have_selector('#mandate_name_error', :text => 'You must select an area')
      check_basis(:special_investigations_unit, "Unreasonable delay")
      expect(page).not_to have_selector('#complaint_basis_id_count_error', :text => 'You must select at least one subarea')
      fill_in('dob', :with => "1950/08/19")
      expect(page).not_to have_selector('#dob_error', :text => "You must enter the complainant's date of birth with format yyyy/mm/dd")
      fill_in('complaint_details', :with => "bish bash bosh")
      expect(page).not_to have_selector('#details_error', :text => "You must enter the complaint details")
    end
  end

  it "shows a single complaint when a query string is appended to the url" do
    create_complaints
    visit complaints_path('en', "html", {:case_reference => "c12-55"})
    expect(page.all('#complaints .complaint').length).to eq 1
    expect(page.all('#complaints .complaint', :visible => false).length).to eq 4
    expect(page.find('#complaints_controls #case_reference').value).to eq "c12-55"
  end
end
