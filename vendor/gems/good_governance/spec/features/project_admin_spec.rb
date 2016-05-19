require 'rails_helper'
require_relative '../helpers/good_governance_context_project_admin_spec_helpers'
require 'project_admin_behaviour'

feature "project admin", :js => true do
  include GoodGovernanceContextProjectAdminSpecHelpers
  it_behaves_like "project admin"
end

