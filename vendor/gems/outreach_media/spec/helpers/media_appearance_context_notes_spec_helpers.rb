require 'rspec/core/shared_context'

module MediaAppearanceContextNotesSpecHelpers
  extend RSpec::Core::SharedContext
  before do
    setup_database(nil)
    @note1 = FactoryGirl.create(:note, :notable_type => "MediaAppearance", :created_at => 3.days.ago, :notable_id => MediaAppearance.first.id)
    @note2 = FactoryGirl.create(:note, :notable_type => "MediaAppearance", :created_at => 4.days.ago, :notable_id => MediaAppearance.first.id)
    visit outreach_media_media_appearances_path(:en)
    show_notes.click
    expect(page).to have_selector("h4", :text => 'Notes')
    sleep(0.3)
  end
end
