require 'rspec/core/shared_context'

module IndicatorsFileMonitorSpecSetupHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:heading)
    FactoryGirl.create(:human_rights_attribute)
    FactoryGirl.create(:indicator,
                       :monitor_format => 'file',
                       #:reminders=>[FactoryGirl.create(:reminder, :indicator)],
                       #:notes => [FactoryGirl.create(:note, :indicator, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :indicator, :created_at => 4.days.ago.to_datetime)],
                       :file_monitor => FactoryGirl.create(:file_monitor, :created_at => 3.days.ago, :user => User.first))
    #resize_browser_window

    Nhri::FileMonitor.permitted_filetypes = ["pdf"]
    Nhri::FileMonitor.maximum_filesize = 5

    visit nhri_heading_path(:en, Nhri::Heading.first.id)
    show_monitors.click
    sleep(0.3) # css transition
  end
end
