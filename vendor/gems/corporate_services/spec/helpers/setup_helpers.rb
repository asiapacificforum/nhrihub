require 'rspec/core/shared_context'

module SetupHelpers
  extend RSpec::Core::SharedContext
  def setup_activity
    sp = StrategicPlan.create(:created_at => 6.months.ago.to_date)
    spl = StrategicPriority.create(:strategic_plan_id => sp.id, :priority_level => 1, :description => "Gonna do things betta")
    pr = PlannedResult.create(:strategic_priority_id => spl.id, :description => "Something profound")
    o = Outcome.create(:planned_result_id => pr.id, :description => "ultimate enlightenment")
    Activity.create(:description => "Smarter thinking", :outcome_id => o.id)
  end

  def setup_performance_indicator
    a = setup_activity
    PerformanceIndicator.create(:description => "number of complaints", :target => "none at all", :activity_id => a.id)
  end

  def setup_strategic_plan
    @performance_indicator = setup_performance_indicator
  end

  def setup_media_appearances(n=1)
    n.times do
      ma = FactoryGirl.build(:media_appearance)
      ma.performance_indicators = [@performance_indicator]
      ma.save
    end
  end

  def setup_projects
    p = FactoryGirl.build(:project)
    p.performance_indicators = [@performance_indicator]
    p.save
  end
end
