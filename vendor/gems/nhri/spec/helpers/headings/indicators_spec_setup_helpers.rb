require 'rspec/core/shared_context'

module IndicatorsSpecSetupHelpers
  extend RSpec::Core::SharedContext
  before do
    heading = FactoryGirl.create(:heading)
    offence = FactoryGirl.create(:offence, :description => "First offence")
    2.times do
      FactoryGirl.create(:indicator,
                         :monitor_format => 'numeric',
                         :offence_id => offence.id,
                         :nature => 'Structural',
                         :heading_id => heading.id,
                         :numeric_monitor_explanation => 'percentage of dogs that like cats',
                         :reminders=>[FactoryGirl.create(:reminder, :indicator)],
                         :notes => [FactoryGirl.create(:note, :indicator, :created_at => 3.days.ago.to_datetime)])
    end
    #resize_browser_window
    visit nhri_heading_path(:en, Nhri::Heading.first.id)
    sleep(0.3) # css transition
  end
end
