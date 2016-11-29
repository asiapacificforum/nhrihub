require 'rspec/core/shared_context'
require_relative '../helpers/media_setup_helper'

module MediaAppearanceContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include MediaSetupHelper

  before do
    setup_database(nil)
    setup_file_constraints
    visit media_appearances_path(:en)
    expect(reminders_icon['data-count']).to eq "1"
    open_reminders_panel
  end
end
