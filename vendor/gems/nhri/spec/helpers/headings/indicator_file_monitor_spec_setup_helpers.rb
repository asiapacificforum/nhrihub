require 'rspec/core/shared_context'

module IndicatorsFileMonitorSpecSetupHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:heading)
    FactoryGirl.create(:offence)
    FactoryGirl.create(:indicator,
                       :monitor_format => 'file',
                       #:reminders=>[FactoryGirl.create(:reminder, :indicator)],
                       #:notes => [FactoryGirl.create(:note, :indicator, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :indicator, :created_at => 4.days.ago.to_datetime)],
                       :file_monitor => FactoryGirl.create(:file_monitor, :created_at => 3.days.ago, :user => User.first))
    #resize_browser_window
    visit nhri_heading_path(:en, Nhri::Heading.first.id)
    show_monitors.click
    sleep(0.3) # css transition
  end
end
