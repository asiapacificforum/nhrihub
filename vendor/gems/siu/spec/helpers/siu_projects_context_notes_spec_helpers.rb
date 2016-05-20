require 'rspec/core/shared_context'

module SiuProjectsContextNotesSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:siu_project,
                       :reminders=>[FactoryGirl.create(:reminder, :siu_project)],
                       :notes =>   [FactoryGirl.create(:note, :siu_project, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :advisory_council_issue, :created_at => 4.days.ago.to_datetime)])
    resize_browser_window
    visit siu_projects_path(:en)
    open_notes_modal
  end
end
