require 'rails_helper'
require 'login_helpers'
require 'complaints_spec_setup_helpers'
require 'navigation_helpers'
require 'complaints_spec_helpers'

feature "complaints index", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers

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
      expect(all('#status_changes .status_change').first.text).to match /#{Complaint.first.status_changes.first.status_humanized}/
      expect(all('#status_changes .status_change').last.text).to match /#{Complaint.first.status_changes.last.status_humanized}/
      expect(find('.complainant').text).to eq Complaint.first.complainant
    end
  end

  it "expands each complaint to show additional information" do
    within first_complaint do
      expand
      expect(find('.complainant_village').text).to eq Complaint.first.village
      expect(find('.complainant_phone').text).to eq Complaint.first.phone

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
        expect(all('.status_change .user_name')[0].text).to eq User.first.first_last_name
        expect(all('.status_change .user_name')[1].text).to eq User.second.first_last_name
        expect(all('.status_change .date')[0].text).to eq Complaint.first.status_changes[0].created_at.localtime.to_date.to_s(:short)
        expect(all('.status_change .date')[1].text).to eq Complaint.first.status_changes[1].created_at.localtime.to_date.to_s(:short)
        expect(all('.status_change .status_humanized')[0].text).to eq "open"
        expect(all('.status_change .status_humanized')[1].text).to eq "closed"
      end

      within complaint_documents do
        Complaint.first.complaint_documents.map(&:title).each do |title|
          expect(all('.complaint_document .title').map(&:text)).to include title
        end
      end

      within complaint_categories do
        Complaint.first.complaint_categories.map(&:name).each do |category_name|
          expect(all('.complaint_category .name').map(&:text)).to include category_name
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

      within mandates do
        expect(find('.mandate').text).to eq "Human Rights"
      end

      within agencies do
        expect(all('.agency').map(&:text)).to include "SAA"
      end

    end # /within first
  end # /it

  it "adds a new complaint" do
    add_complain
    fill_in('complainant', :with => "Norman Normal")
    fill_in('village', :with => "Normaltown")
    fill_in('phone', :with => "555-1212")
    check('special_investigations_unit')
    check_basis(:good_governance, "Delayed action")
    check_basis(:human_rights, "CAT")
    check_basis(:special_investigations_unit, "Unreasonable delay")
    select(User.first.first_last_name, :from => "assignee")
    check_category("Formal")
    check_agency("SAA")
    check_agency("ACC")
    within new_complaint do
      attach_file
      fill_in("complaint_document_title", :with => "Complaint Document")
    end
    expect(page).to have_selector("#documents .document .filename", :text => "first_upload_file.pdf")

    next_ref = Complaint.next_case_reference
    expect(new_complaint_case_reference).to eq next_ref
    expect{save_complaint.click; wait_for_ajax}.to change{ Complaint.count }.by(1)
                                               .and change{ page.all('.complaint').count }.by(1)
                                               .and change{ page.all('.new_complaint').count }.by(-1)
    # on the server
    expect(Complaint.last.case_reference).to eq next_ref
    expect(Complaint.last.complainant).to eq "Norman Normal"
    expect(Complaint.last.village).to eq "Normaltown"
    expect(Complaint.last.phone).to eq "555-1212"
    expect(Complaint.last.mandates.map(&:key)).to include 'special_investigations_unit'
    expect(Complaint.last.good_governance_complaint_bases.map(&:name)).to include "Delayed action"
    expect(Complaint.last.human_rights_complaint_bases.map(&:name)).to include "CAT"
    expect(Complaint.last.special_investigations_unit_complaint_bases.map(&:name)).to include "Unreasonable delay"
    expect(Complaint.last.current_assignee_name).to eq User.first.first_last_name
    expect(Complaint.last.status_changes.count).to eq 1
    expect(Complaint.last.status_changes.first.new_value).to eq true
    expect(Complaint.last.complaint_categories.map(&:name)).to include "Formal"
    expect(Complaint.last.agencies.map(&:name)).to include "SAA"
    expect(Complaint.last.agencies.map(&:name)).to include "ACC"
    expect(Complaint.last.complaint_documents.count).to eq 1
    expect(Complaint.last.complaint_documents[0].filename).to eq "first_upload_file.pdf"
    expect(Complaint.last.complaint_documents[0].title).to eq "Complaint Document"
    # on the client
    expect(first_complaint.find('.case_reference').text).to eq next_ref
    expect(first_complaint.find('.current_assignee').text).to eq User.first.first_last_name
    expect(first_complaint.find('.complainant').text).to eq "Norman Normal"
    expect(first_complaint.find('#status_changes .status_change .status_humanized').text).to eq 'open'
    expand
    expect(first_complaint.find('.complainant_village').text).to eq "Normaltown"
    expect(first_complaint.find('.complainant_phone').text).to eq "555-1212"

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

    within complaint_categories do
      expect(page.all('.name').map(&:text)).to include "Formal"
    end

    within agencies do
      expect(all('.agency').map(&:text)).to include "SAA"
      expect(all('.agency').map(&:text)).to include "ACC"
    end

    within complaint_documents do
      expect(page.all('#complaint_documents .complaint_document')[0].find('.filename').text).to eq "first_upload_file.pdf"
      expect(page.all('#complaint_documents .complaint_document')[0].find('.title').text).to eq "Complaint Document"
    end
  end

  it "cancels adding" do
    add_complaint
    fill_in('complainant', :with => "Norman Normal")
    fill_in('village', :with => "Normaltown")
    fill_in('phone', :with => "555-1212")
    check('special_investigations_unit')
    check_basis(:good_governance, "Delayed action")
    check_basis(:human_rights, "CAT")
    check_basis(:special_investigations_unit, "Unreasonable delay")
    select(User.first.first_last_name, :from => "assignee")
    cancel_add
    expect(page).not_to have_selector('.new_complaint')
    add_complaint
    expect(page.find('#complainant').value).to be_blank
    expect(page.find('#village').value).to be_blank
    expect(page.find('#phone').value).to be_blank
    expect(basis_checkbox(:good_governance, "Delayed action")).not_to be_checked
    expect(basis_checkbox(:human_rights, "CAT")).not_to be_checked
    expect(basis_checkbox(:special_investigations_unit, "Unreasonable delay")).not_to be_checked
  end

  it "changes complaint current status by adding a status_change" do
    edit_complaint
    within current_status do
      expect(page).to have_checked_field "close"
      choose "open"
    end
    expect{ edit_save; wait_for_ajax }.to change{ Complaint.first.current_status }.from(false).to(true)
    expect( first_complaint.all('#status_changes .status_change').last.text ).to match "open"
    expect( first_complaint.all('#status_changes .date').last.text ).to match /#{Date.today.to_s(:short)}/
    user = User.find_by(:login => 'admin')
    expect( first_complaint.all('#status_changes .user_name').last.text ).to match /#{user.first_last_name}/
  end

  it "edits a complaint" do
    edit_complaint
    # COMPLAINANT
    fill_in('complainant', :with => "Norman Normal")
    fill_in('village', :with => "Normaltown")
    fill_in('phone', :with => "555-1212")
    # CATEGORY
    check_category("Informal")
    uncheck_category("Formal")
    # ASSIGNEE
    select(User.last.first_last_name, :from => "assignee")
    # MANDATE
    check('special_investigations_unit') # originally had human rights mandate, now should have both
    # BASIS
    uncheck_basis(:good_governance, "Delayed action") # originally had "Delayed action" and "Failure to Act"
    uncheck_basis(:human_rights, "CAT") # originall had "CAT" "ICESCR"
    uncheck_basis(:special_investigations_unit, "Unreasonable delay") #originally had "Unreasonable delay" "Not properly investigated"
    # AGENCY
    uncheck_agency("SAA")
    check_agency("ACC")
    # DOCUMENTS TODO
    attach_file
    fill_in("complaint_document_title", :with => "added complaint document")
    expect(page).to have_selector("#complaint_documents .document .filename", :text => "first_upload_file.pdf")
    expect{ edit_save; wait_for_ajax }.to change{ Complaint.first.complainant }.to("Norman Normal").
                                      and change{ Complaint.first.village }.to("Normaltown").
                                      and change{ Complaint.first.phone }.to("555-1212").
                                      and change{ Complaint.first.assignees.count }.by(1).
                                      and change{ Complaint.first.complaint_documents.count }.by 1

    expect( Complaint.first.mandates.map(&:key) ).to include "special_investigations_unit"
    expect( Complaint.first.mandates.map(&:key) ).to include "human_rights"
    expect( Complaint.first.good_governance_complaint_bases.count ).to eq 1
    expect( Complaint.first.good_governance_complaint_bases.first.name ).to eq "Failure to act"
    expect( Complaint.first.human_rights_complaint_bases.count ).to eq 1
    expect( Complaint.first.human_rights_complaint_bases.first.name ).to eq "ICESCR"
    expect( Complaint.first.special_investigations_unit_complaint_bases.count ).to eq 1
    expect( Complaint.first.special_investigations_unit_complaint_bases.first.name ).to eq "Not properly investigated"
    expect( Complaint.first.complaint_categories.map(&:name) ).to include "Informal"
    expect( Complaint.first.complaint_categories.count ).to eq 1
    expect( Complaint.first.assignees ).to include User.last
    expect( Complaint.first.agencies.map(&:name) ).to include "ACC"
    expect( Complaint.first.agencies.count ).to eq 1

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

    within complaint_categories do
      expect(page.all('.name').map(&:text)).to include "Informal"
    end

    within agencies do
      expect(all('.agency').map(&:text)).to include "ACC"
    end

    within complaint_documents do
      expect(page.all('#complaint_documents .complaint_document .filename').map(&:text)).to include "first_upload_file.pdf"
      expect(page.all('#complaint_documents .complaint_document .title').map(&:text)).to include "added complaint document"
    end
  end

  it "edits a complaint, deleting a file" do
    edit_complaint
    expect{delete_document; wait_for_ajax}.to change{ Complaint.first.complaint_documents.count }.by(-1).
                                          and change{ complaint_documents.count }.by(-1)
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
    fill_in('complainant', :with => "Norman Normal")
    fill_in('village', :with => "Normaltown")
    fill_in('phone', :with => "555-1212")
    #check_basis(:good_governance, "Delayed action")
    #check_basis(:human_rights, "CAT")
    #check_basis(:special_investigations_unit, "Unreasonable delay")
    edit_cancel
    edit_complaint
    expect(page.find('#complainant').value).to eq original_complaint.complainant
    expect(page.find('#village').value).to eq original_complaint.village
    expect(page.find('#phone').value).to eq original_complaint.phone
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
    expect(page.find('#complainant').value).to be_blank
    expect(page.find('#village').value).to be_blank
    expect(page.find('#phone').value).to be_blank
  end

  it "terminates editing complaint when adding is initiated" do
    original_complaint = Complaint.first
    edit_first_complaint
    fill_in('complainant', :with => "Norman Normal")
    fill_in('village', :with => "Normaltown")
    fill_in('phone', :with => "555-1212")
    add_complaint
    expect(page.evaluate_script("_.chain(complaints.findAllComponents('complaint')).map(function(c){return c.get('editing')}).filter(function(c){return c}).value().length")).to eq 0
    cancel_add
    edit_first_complaint
    expect(page.find('#complainant').value).to eq original_complaint.complainant
    expect(page.find('#village').value).to eq original_complaint.village
    expect(page.find('#phone').value).to eq original_complaint.phone
  end

  it "deletes a complaint" do
    expect{delete_complaint; wait_for_ajax}.to change{ Complaint.count }.by(-1).
                                           and change{ complaints.count }.by(-1)
  end
end
