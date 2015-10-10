require 'rspec/core/shared_context'
require 'reminders_spec_common_helpers'
require_relative '../helpers/setup_helpers'
require_relative '../helpers/strategic_plan_helpers'

module CorporateServicesContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include SetupHelpers
  include StrategicPlanHelpers

  before do
    activity = setup_activity
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :users => [User.first], :remindable => activity)
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    open_reminders_panel
  end
end
