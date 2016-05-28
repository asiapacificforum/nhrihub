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
      expect(find('.status').text).to eq Complaint.first.status_humanized
      expect(find('.complainant').text).to eq Complaint.first.complainant
    end
  end

  it "expands each complaint to show additional information" do
    within first_complaint do
      expand
      expect(find('.complainant_village').text).to eq Complaint.first.village
      expect(find('.complainant_phone').text).to eq Complaint.first.phone
      #TODO waiting on clarification, so we display ONLY complaint bases for
      # the associate mandate, or can a complaint have bases for other mandates?
      #Complaint.first.complaint_bases.each do |complaint_basis|
        #expect(find('.complaint_bases').text).to include(complaint_basis.name)
      #end
      within assignee_history do
        Complaint.first.assigns.map(&:name).each do |name|
          expect(all('.name').map(&:text)).to include name
        end # /do
        Complaint.first.assigns.map(&:date).each do |date|
          expect(all('.date').map(&:text)).to include date
        end # /do
      end # /within

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
    end # /within first
  end # /it

  it "adds a new complaint" do
    add_complaint.click
    fill_in('complainant', :with => "Norman Normal")
    fill_in('village', :with => "Normaltown")
    fill_in('phone', :with => "555-1212")
    check('special_investigations_unit')
    check_basis(:good_governance, "Delayed action")
    check_basis(:human_rights, "CAT")
    check_basis(:special_investigations_unit, "Unreasonable delay")
    next_ref = Complaint.next_case_reference
    expect(new_complaint_case_reference).to eq next_ref
    expect{save_complaint.click; wait_for_ajax}.to change{ Complaint.count }.by(1)
                                               .and change{ page.all('.complaint').count }.by(1)
                                               .and change{ page.all('.new_complaint').count }.by(-1)
    expect(Complaint.last.case_reference).to eq next_ref
    expect(Complaint.last.complainant).to eq "Norman Normal"
    expect(Complaint.last.village).to eq "Normaltown"
    expect(Complaint.last.phone).to eq "555-1212"
    expect(Complaint.last.mandates.map(&:key)).to include 'special_investigations_unit'
    expect(Complaint.last.good_governance_complaint_bases.map(&:name)).to include "Delayed action"
    expect(Complaint.last.human_rights_complaint_bases.map(&:name)).to include "CAT"
    expect(Complaint.last.special_investigations_unit_complaint_bases.map(&:name)).to include "Unreasonable delay"
    expect(first_complaint.find('.case_reference').text).to eq next_ref
  end
end
