require 'rspec/core/shared_context'
require_relative '../helpers/setup_helpers'
require_relative '../helpers/strategic_plan_helpers'

module CorporateServicesContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include SetupHelpers
  include StrategicPlanHelpers

  before do
    setup_performance_indicator
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :user => User.first, :remindable => PerformanceIndicator.first)
    visit corporate_services_strategic_plan_path(:en, StrategicPlan.most_recent.id)
    open_accordion_for_strategic_priority_one
    expect(reminders_icon['data-count']).to eq "1"
    open_reminders_panel
  end
end
