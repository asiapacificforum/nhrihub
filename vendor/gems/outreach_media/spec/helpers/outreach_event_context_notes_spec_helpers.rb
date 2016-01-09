require 'rspec/core/shared_context'

module OutreachEventContextNotesSpecHelpers
  extend RSpec::Core::SharedContext
  before do
    setup_database(nil)
    @note1 = FactoryGirl.create(:note, :notable_type => "OutreachEvent", :created_at => 3.days.ago, :notable_id => OutreachEvent.first.id)
    @note2 = FactoryGirl.create(:note, :notable_type => "OutreachEvent", :created_at => 4.days.ago, :notable_id => OutreachEvent.first.id)
    visit outreach_media_outreach_events_path(:en)
    show_notes.click
    expect(page).to have_selector("h4", :text => 'Notes')
    sleep(0.3)
  end
end
