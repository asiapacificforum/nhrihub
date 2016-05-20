require 'rspec/core/shared_context'

module NhriProjectsContextNotesSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    FactoryGirl.create(:nhri_protection_promotion_project,
                       :reminders=>[FactoryGirl.create(:reminder, :nhri_protection_promotion_project)],
                       :notes =>   [FactoryGirl.create(:note, :nhri_protection_promotion_project, :created_at => 3.days.ago.to_datetime),
                                    FactoryGirl.create(:note, :nhri_protection_promotion_project, :created_at => 4.days.ago.to_datetime)])
    resize_browser_window
    visit nhri_protection_promotion_projects_path(:en)
    open_notes_modal
  end
end
