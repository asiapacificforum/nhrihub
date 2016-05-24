require 'navigation_helpers'
require 'complaints_behaviour_helpers'

# in NHRI
#    Good Governance
#    Special Investigations Unit
RSpec.shared_examples "complaints index" do
  include NavigationHelpers
  include ComplaintsBehaviourHelpers
  it "shows a list of complaints" do
    expect(page.find('h1').text).to eq "#{heading_prefix} Complaints"
    expect(page).to have_selector('#complaints .complaint', :count => 1)
  end

  it "shows basic information for each complaint" do
    within first_complaint do
      expect(find('.current_assignee').text).to eq model.first.assignees.first.first_last_name
      expect(find('.status').text).to eq model.first.status_humanized
      expect(find('.complainant').text).to eq model.first.complainant
    end
  end

  it "expands each complaint to show additional information" do
    within first_complaint do
      expand
      expect(find('.complainant_village').text).to eq model.first.village
      expect(find('.complainant_phone').text).to eq model.first.phone
      #TODO waiting on clarification, so we display ONLY complaint bases for
      # the associate mandate, or can a complaint have bases for other mandates?
      #model.first.complaint_bases.each do |complaint_basis|
        #expect(find('.complaint_bases').text).to include(complaint_basis.name)
      #end
      within assignee_history do
        model.first.assigns.map(&:name).each do |name|
          expect(all('.name').map(&:text)).to include name
        end # /do
        model.first.assigns.map(&:date).each do |date|
          expect(all('.date').map(&:text)).to include date
        end # /do
      end # /within

      within complaint_documents do
        model.first.complaint_documents.map(&:title).each do |title|
          expect(all('.complaint_document .title').map(&:text)).to include title
        end
      end
    end # /within
  end # /it

  it "adds a new complaint" do
    add_complaint.click
  end
end
