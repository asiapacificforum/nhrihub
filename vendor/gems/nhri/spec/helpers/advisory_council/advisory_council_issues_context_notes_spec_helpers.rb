require 'rspec/core/shared_context'

module AdvisoryCouncilIssuesContextNotesSpecHelpers
  extend RSpec::Core::SharedContext

  before do
    setup_positivity_ratings
    setup_areas
    FactoryGirl.create(:advisory_council_issue,
                       :hr_area,
                       :positivity_rating => PositivityRating.first,
                       :reminders=>[FactoryGirl.create(:reminder, :advisory_council_issue)],
                       :notes => [FactoryGirl.create(:note, :advisory_council_issue, :created_at => 3.days.ago.to_datetime),FactoryGirl.create(:note, :advisory_council_issue, :created_at => 4.days.ago.to_datetime)])
    #resize_browser_window
    visit nhri_advisory_council_issues_path(:en)
    page.all('.show_notes')[0].click
    sleep(0.3) # css transition
  end
end
