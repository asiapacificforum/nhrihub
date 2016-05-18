require 'rspec/core/shared_context'
require 'reminders_spec_common_helpers'
require 'projects_spec_setup_helpers'
require 'reminder_page_helpers'

module GoodGovernanceContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include ProjectsSpecSetupHelpers
  include ReminderPageHelpers

  before do
    populate_database
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :users => [User.first], :remindable => GoodGovernance::Project.first)
    visit good_governance_projects_path(:en)
    open_reminders_panel
  end

  def populate_database
    FactoryGirl.create(:good_governance_project)
  end
end

