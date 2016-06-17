require 'rspec/core/shared_context'
require_relative '../helpers/outreach_setup_helper'

module OutreachEventContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include OutreachSetupHelper

  before do
    setup_database(nil)
    visit outreach_media_outreach_events_path(:en)
    expect(reminders_icon['data-count']).to eq "1"
    open_reminders_panel
  end
end
