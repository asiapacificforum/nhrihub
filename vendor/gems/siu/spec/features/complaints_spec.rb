require 'rails_helper'
require 'complaints_behaviour'
require_relative '../helpers/siu_context_complaints_helpers'

feature "complaints index", :js => true do
  include SiuContextComplaintsHelpers
  it_behaves_like "complaints index"
end
