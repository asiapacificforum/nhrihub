require 'rspec/core/shared_context'

module IndicatorsSpecSetupHelpers
  extend RSpec::Core::SharedContext
  before do
    FactoryGirl.create(:heading)
    FactoryGirl.create(:offence)
    FactoryGirl.create(:indicator,
                       :reminders=>[FactoryGirl.create(:reminder, :indicator)],
                       :notes => [FactoryGirl.create(:note, :indicator, :created_at => 3.days.ago.to_datetime)],
                       :monitors => [FactoryGirl.create(:monitor, :date => 3.days.ago)])
    #resize_browser_window
    visit nhri_heading_path(:en, Nhri::Indicator::Heading.first.id)
    sleep(0.3) # css transition
  end
end
