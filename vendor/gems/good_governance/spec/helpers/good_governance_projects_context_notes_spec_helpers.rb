require 'rspec/core/shared_context'

module GoodGovernanceProjectsContextNotesSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:good_governance_project,
                       :reminders=>[FactoryGirl.create(:reminder, :good_governance_project)],
                       :notes =>   [FactoryGirl.create(:note, :good_governance_project, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :advisory_council_issue, :created_at => 4.days.ago.to_datetime)])
    resize_browser_window
    visit good_governance_projects_path(:en)
    open_notes_modal
  end
end
