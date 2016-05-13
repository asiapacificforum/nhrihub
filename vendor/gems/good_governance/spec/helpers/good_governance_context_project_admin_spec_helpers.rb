require 'rspec/core/shared_context'

module GoodGovernanceContextProjectAdminSpecHelpers
  extend RSpec::Core::SharedContext

  def admin_path
    good_governance_admin_path('en')
  end

  def config_key
    "project_document"
  end
end
