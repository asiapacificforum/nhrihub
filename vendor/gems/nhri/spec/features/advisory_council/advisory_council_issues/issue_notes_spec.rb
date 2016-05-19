require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../../helpers/advisory_council/advisory_council_issues_setup_helper'
require_relative '../../../helpers/advisory_council/notes_spec_helpers'
require_relative '../../../helpers/advisory_council/advisory_council_issues_context_notes_spec_helpers'
require 'notes_behaviour'


feature "advisory council issue notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSetupHelper
  include NotesSpecHelpers
  include AdvisoryCouncilIssuesContextNotesSpecHelpers
  it_behaves_like "notes"
end
