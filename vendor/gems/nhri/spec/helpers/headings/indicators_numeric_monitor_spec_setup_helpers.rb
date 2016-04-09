require 'rspec/core/shared_context'

module IndicatorsNumericMonitorSpecSetupHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:heading)
    FactoryGirl.create(:human_rights_attribute)
    FactoryGirl.create(:indicator,
                       :monitor_format => 'numeric',
                       :numeric_monitor_explanation => "Numeric monitor explanation text",
                       :reminders=>[FactoryGirl.create(:reminder, :indicator)],
                       :notes => [FactoryGirl.create(:note, :indicator, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :indicator, :created_at => 4.days.ago.to_datetime)],
                       :numeric_monitors => [FactoryGirl.create(:numeric_monitor, :date => 3.days.ago),FactoryGirl.create(:numeric_monitor, :date => 4.days.ago)])
    #resize_browser_window
    visit nhri_heading_path(:en, Nhri::Heading.first.id)
    show_monitors.click
    sleep(0.3) # css transition
  end
end
