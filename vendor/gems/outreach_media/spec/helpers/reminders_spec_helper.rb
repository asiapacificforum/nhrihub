require 'rspec/core/shared_context'

module RemindersSpecHelpers
  extend RSpec::Core::SharedContext
  def open_reminders_panel
    reminders_icon.click
  end

  def reminders_icon
    page.find(".row.media_appearance div.actions div.alarm_icon")
  end
end
