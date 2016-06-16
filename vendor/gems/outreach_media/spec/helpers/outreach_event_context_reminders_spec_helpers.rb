require 'rspec/core/shared_context'
require_relative '../helpers/outreach_setup_helper'

module OutreachEventContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include OutreachSetupHelper

  before do
    setup_database(nil)
    add_reminder
    visit outreach_media_outreach_events_path(:en)
    open_reminders_panel
  end
end
