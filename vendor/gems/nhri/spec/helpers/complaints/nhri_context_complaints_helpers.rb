require 'rspec/core/shared_context'
require 'login_helpers'

module NhriContextComplaintsHelpers
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    populate_database(:nhri)
    visit nhri_complaints_path('en')
  end

  def heading_prefix
    "NHRI"
  end

  def model
    Nhri::Complaint
  end
end
