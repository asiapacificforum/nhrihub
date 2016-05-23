require 'rspec/core/shared_context'
require 'login_helpers'

module NhriContextComplaintsHelpers
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    populate_database
    visit nhri_complaints_path('en')
  end

  def heading_prefix
    "NHRI"
  end

  def populate_database
    FactoryGirl.create(:complaint, :nhri, :case_reference => "c12/34", :status => true,
                       :assignees => [FactoryGirl.create(:assignee, :with_password),FactoryGirl.create(:assignee, :with_password)])
  end

  def model
    Nhri::Complaint
  end
end
