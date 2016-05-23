require 'rspec/core/shared_context'
require 'login_helpers'

module GoodGovernanceContextComplaintsHelpers
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    populate_database
    visit good_governance_complaints_path('en')
  end

  def heading_prefix
    "Good Governance"
  end

  def populate_database
    FactoryGirl.create(:complaint, :gg, :case_reference => "c12/34", :status => true,
                       :assignees => [FactoryGirl.create(:assignee, :with_password),FactoryGirl.create(:assignee, :with_password)])
  end

  def model
    GoodGovernance::Complaint
  end
end
