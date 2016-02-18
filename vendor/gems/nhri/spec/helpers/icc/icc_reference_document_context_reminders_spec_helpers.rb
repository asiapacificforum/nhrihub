require 'rspec/core/shared_context'
require_relative '../icc/icc_setup_helper'
require_relative '../icc/reminders_spec_helper'

module IccReferenceDocumentContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include IccSetupHelper
  include RemindersSpecHelpers

  before do
    setup_database
    add_reminder
    visit nhri_reference_documents_path(:en)
    open_reminders_panel
  end

  def add_reminder
    puts "arm"
  end

  def open_reminders_panel
    puts "open remm pan"
  end

  def reminders_icon
    puts "ha ha"
  end
end
