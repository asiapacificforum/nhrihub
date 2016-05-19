require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/good_governance_projects_context_notes_spec_helpers'
require 'helpers/notes_spec_common_helpers'
require 'notes_behaviour'


feature "good governance projects notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include GoodGovernanceProjectsContextNotesSpecHelpers
  include NotesSpecCommonHelpers
  it_behaves_like "notes"
end
