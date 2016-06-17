require 'rspec/core/shared_context'

module ComplaintsRemindersSetupHelpers
  extend RSpec::Core::SharedContext

  before do
    populate_database
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :users => [User.first], :remindable => Complaint.first)
    visit complaints_path(:en)
    open_reminders_panel
  end

  def populate_database
    FactoryGirl.create(:complaint)
  end
end
