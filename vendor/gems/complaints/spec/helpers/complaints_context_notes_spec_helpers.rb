require 'rspec/core/shared_context'

module ComplaintsContextNotesSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:complaint,
                       :reminders=>[FactoryGirl.create(:reminder, :complaint)],
                       :notes =>   [FactoryGirl.create(:note, :complaint, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :advisory_council_issue, :created_at => 4.days.ago.to_datetime)])
    resize_browser_window
    visit complaints_path(:en)
    open_notes_modal
  end
end

