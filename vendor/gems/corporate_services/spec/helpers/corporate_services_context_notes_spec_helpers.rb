require 'rspec/core/shared_context'

module CorporateServicesContextNotesSpecHelpers
  extend RSpec::Core::SharedContext
  before do
    setup_activity
    @note1 = FactoryGirl.create(:note, :notable_type => "Activity", :created_at => 3.days.ago, :notable_id => Activity.first.id)
    @note2 = FactoryGirl.create(:note, :notable_type => "Activity", :created_at => 4.days.ago, :notable_id => Activity.first.id)
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    show_notes.click
    expect(page).to have_selector("h4", :text => 'Notes')
    sleep(0.3)
  end
end
