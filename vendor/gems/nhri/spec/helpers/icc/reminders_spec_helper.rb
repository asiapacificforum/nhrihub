require 'rspec/core/shared_context'
require 'reminders_spec_common_helpers'

module RemindersSpecHelpers
  extend RSpec::Core::SharedContext
  #include RemindersSpecCommonHelpers

  def open_reminders_panel
    reminders_icon.click
    page.find('i#add_reminder', :visible => true, :wait => 20)
    sleep(0.2) # b/c capy finds it on the page before css transitions are complete, I think
  end

  def reminders_icon
    page.find("table.icc_reference_document .alarm_icon")
  end
end
