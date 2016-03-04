require 'rails_helper'
require 'login_helpers'
require_relative '../../../helpers/advisory_council/advisory_council_issues_setup_helper'
#require_relative '../../../helpers/advisory_council/reminders_spec_helpers'
require_relative '../../../helpers/advisory_council/advisory_council_issues_context_reminders_spec_helpers'
require 'reminders_behaviour'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSetupHelper
  include AdvisoryCouncilIssuesContextRemindersSpecHelpers
  it_behaves_like "reminders"
end
