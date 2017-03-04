require 'rspec/core/shared_context'

module IndicatorsContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:heading)
    FactoryGirl.create(:human_rights_attribute)
    FactoryGirl.create(:indicator, :with_reminder, :with_notes)
    visit nhri_heading_path(:en, Nhri::Heading.first.id)
    page.all('.alarm_icon')[0].click
    sleep(0.3) # css transition
  end
end
