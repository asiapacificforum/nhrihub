require 'rspec/core/shared_context'

module SetupHelpers
  extend RSpec::Core::SharedContext
  def setup_activity
    sp = StrategicPlan.create(:start_date => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
  end
end
