require 'rspec/core/shared_context'
require 'login_helpers'

module SiuContextComplaintsHelpers
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  before do
    populate_database
    visit siu_complaints_path('en')
  end

  def heading_prefix
    "Special Investigations Unit"
  end

  def populate_database
    FactoryGirl.create(:complaint, :siu, :case_reference => "c12/34", :status => true,
                       :assignees => [FactoryGirl.create(:assignee, :with_password),FactoryGirl.create(:assignee, :with_password)])
  end

  def model
    Siu::Complaint
  end
end
