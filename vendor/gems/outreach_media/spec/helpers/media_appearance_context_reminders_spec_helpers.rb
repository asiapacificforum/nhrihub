require 'rspec/core/shared_context'
require_relative '../helpers/setup_helper'
require_relative '../helpers/reminders_spec_helper'

module MediaAppearanceContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include SetupHelper
  include RemindersSpecHelpers

  before do
    setup_database(nil)
    add_reminder
    visit outreach_media_media_appearances_path(:en)
    open_reminders_panel
  end
end
