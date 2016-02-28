require 'rspec/core/shared_context'

module AdvisoryCouncilMembershipSpecSetupHelper
  extend RSpec::Core::SharedContext

  def setup_membership_database
    3.times do
      FactoryGirl.create(:advisory_council_member)
    end
  end
end
