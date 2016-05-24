require 'rails_helper'
require 'complaints_behaviour'
require 'complaints_spec_common_helpers'
require_relative './../../helpers/complaints/nhri_context_complaints_helpers'

feature "complaints index", :js => true do
  include ComplaintsSpecCommonHelpers
  include NhriContextComplaintsHelpers
  it_behaves_like "complaints index"
end
