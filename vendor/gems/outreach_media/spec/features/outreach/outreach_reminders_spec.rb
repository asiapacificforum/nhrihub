require 'rails_helper'
require 'login_helpers'
require_relative '../../helpers/outreach_event_context_reminders_spec_helpers.rb'
require 'reminders_behaviour'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachEventContextRemindersSpecHelpers
  it_behaves_like "reminders"
end
