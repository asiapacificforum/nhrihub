require 'rails_helper'
require 'login_helpers'
require_relative '../../helpers/icc/icc_reference_document_context_reminders_spec_helpers'
require 'reminders_behaviour'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccReferenceDocumentContextRemindersSpecHelpers
  it_behaves_like "reminders"
end
