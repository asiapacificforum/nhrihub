require 'rspec/core/shared_context'

module IndicatorsContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:heading)
    FactoryGirl.create(:offence)
    FactoryGirl.create(:indicator,
                       :reminders=>[FactoryGirl.create(:reminder, :indicator, :reminder_type => :weekly, :text => "don't forget the fruit gums mum", :users => [User.first])],
                       :notes => [FactoryGirl.create(:note, :indicator, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :indicator, :created_at => 4.days.ago.to_datetime)])
    #resize_browser_window
    visit nhri_heading_path(:en, Nhri::Heading.first.id)
    page.all('.alarm_icon')[0].click
    sleep(0.3) # css transition
  end
end
