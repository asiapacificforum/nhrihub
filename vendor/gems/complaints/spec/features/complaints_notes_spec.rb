require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/complaints_context_notes_spec_helpers'
require 'notes_spec_common_helpers'
require 'notes_behaviour'


feature "complaints notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsContextNotesSpecHelpers
  include NotesSpecCommonHelpers

  before(:context) do
    Webpacker.compile
  end

  it_behaves_like "notes"
end

