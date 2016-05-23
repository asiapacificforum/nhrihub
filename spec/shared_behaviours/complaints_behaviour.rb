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
      expect(find('.current_assignee').text).to eq model.first.assignees.last.first_last_name
      expect(find('.status').text).to eq model.first.status_humanized
      expect(find('.complainant').text).to eq model.first.complainant
    end
  end
end
