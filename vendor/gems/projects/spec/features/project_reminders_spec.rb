require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/siu_context_reminders_spec_helpers'
require 'reminders_behaviour'

feature "show reminders", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include SiuContextRemindersSpecHelpers
  it_behaves_like "reminders"
end

