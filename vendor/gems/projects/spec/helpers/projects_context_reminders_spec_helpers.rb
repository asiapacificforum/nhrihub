require 'rspec/core/shared_context'
require_relative '../helpers/projects_spec_setup_helpers'

module ProjectsContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include ProjectsSpecSetupHelpers

  before do
    populate_database
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :users => [User.first], :remindable => Project.first)
    visit projects_path(:en)
    open_reminders_panel
  end

  def populate_database
    FactoryGirl.create(:project)
  end
end

