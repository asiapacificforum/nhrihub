require 'rspec/core/shared_context'

module ProjectsContextNotesSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    sp = FactoryGirl.create(:project,
                       :reminders=>[FactoryGirl.create(:reminder, :project)],
                       :notes =>   [FactoryGirl.create(:note, :project, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :advisory_council_issue, :created_at => 4.days.ago.to_datetime)])
    visit projects_path(:en)
    open_notes_modal
  end
end
