require 'rspec/core/shared_context'
require 'login_helpers'

module GoodGovernanceContextComplaintsHelpers
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    populate_database(:gg)
    visit good_governance_complaints_path('en')
  end

  def heading_prefix
    "Good Governance"
  end

  def model
    GoodGovernance::Complaint
  end
end
