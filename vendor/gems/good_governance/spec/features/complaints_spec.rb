require 'rails_helper'
require 'complaints_behaviour'
require_relative './../helpers/good_governance_context_complaints_helpers'

feature "complaints index", :js => true do
  include GoodGovernanceContextComplaintsHelpers
  it_behaves_like "complaints index"
end
