require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/outreach_setup_helper'
require_relative '../../helpers/notes_spec_helpers'
require_relative '../../helpers/outreach_event_context_notes_spec_helpers'
require 'notes_behaviour'


feature "outreach notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachSetupHelper
  include NotesSpecHelpers
  include OutreachEventContextNotesSpecHelpers
  it_behaves_like "notes"
end
