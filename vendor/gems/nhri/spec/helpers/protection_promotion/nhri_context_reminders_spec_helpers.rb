require 'rspec/core/shared_context'
require 'reminders_spec_common_helpers'
require 'projects_spec_setup_helpers'
require 'reminder_page_helpers'

module NhriContextRemindersSpecHelpers
  extend RSpec::Core::SharedContext
  include ProjectsSpecSetupHelpers
  include ReminderPageHelpers

  before do
    populate_database
    rem = Reminder.create(:reminder_type => 'weekly',
                          :start_date => Date.new(2015,8,19),
                          :text => "don't forget the fruit gums mum",
                          :users => [User.first], :remindable => Nhri::ProtectionPromotion::Project.first)
    visit nhri_protection_promotion_projects_path(:en)
    open_reminders_panel
  end

  def populate_database
    FactoryGirl.create(:nhri_protection_promotion_project)
  end
end

