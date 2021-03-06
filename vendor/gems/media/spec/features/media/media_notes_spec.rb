require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/media_setup_helper'
require_relative '../../helpers/notes_spec_helpers'
require_relative '../../helpers/media_appearance_context_notes_spec_helpers'
require 'notes_behaviour'


feature "media appearance notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaSetupHelper
  include NotesSpecHelpers
  include MediaAppearanceContextNotesSpecHelpers
  it_behaves_like "notes"
end
