require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
#require 'projects_context_reminders_spec_helpers'
require_relative '../helpers/projects_context_reminders_spec_helpers'
require 'reminders_behaviour'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ProjectsContextRemindersSpecHelpers
  it_behaves_like "reminders"
end

