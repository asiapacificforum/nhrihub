require 'rspec/core/shared_context'
require 'login_helpers'

module SiuContextComplaintsHelpers
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    populate_database(:siu)
    visit siu_complaints_path('en')
  end

  def heading_prefix
    "Special Investigations Unit"
  end

  def model
    Siu::Complaint
  end
end
