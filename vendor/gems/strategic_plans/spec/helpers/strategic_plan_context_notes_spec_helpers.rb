require 'rspec/core/shared_context'

module StrategicPlanContextNotesSpecHelpers
  extend RSpec::Core::SharedContext
  before do
    setup_performance_indicator
    @note1 = FactoryGirl.create(:note, :notable_type => "PerformanceIndicator", :created_at => 3.days.ago, :notable_id => PerformanceIndicator.first.id)
    @note2 = FactoryGirl.create(:note, :notable_type => "PerformanceIndicator", :created_at => 4.days.ago, :notable_id => PerformanceIndicator.first.id)
    visit strategic_plans_strategic_plan_path(:en, StrategicPlan.most_recent.id)
    open_accordion_for_strategic_priority_one
    show_notes.click
    expect(page).to have_selector("h4", :text => 'Notes')
    sleep(0.3)
  end
end
