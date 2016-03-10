require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/headings/notes_spec_helpers'
require_relative '../../helpers/headings/indicators_context_notes_spec_helpers'
require Rails.root.join('spec','helpers','notes_behaviour')


feature "advisory council issue notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NotesSpecHelpers
  include IndicatorsContextNotesSpecHelpers
  it_behaves_like "notes"
end
