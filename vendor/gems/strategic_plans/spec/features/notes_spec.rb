require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/setup_helpers'
require_relative '../helpers/notes_spec_helpers'
require_relative '../helpers/strategic_plan_context_notes_spec_helpers'
require 'notes_behaviour'


feature "activity notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include SetupHelpers
  include NotesSpecHelpers
  include StrategicPlanContextNotesSpecHelpers
  it_behaves_like "notes"
end
