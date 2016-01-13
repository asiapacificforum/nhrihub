require 'rails_helper'

describe "#indexed_description" do
  context "for the first in the outcome" do
    before do
      stp = StrategicPlan.create(:start_date => 6.months.ago.to_date )
      @sp = StrategicPriority.create(:description => 'first strategic priority', :priority_level => 1, :strategic_plan_id => stp.id)
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "first planned result")
      @outcome = Outcome.create(:planned_result_id => @planned_result.id, :description => "first outcome")
      @activity = Activity.create(:outcome_id => @outcome.id, :description => 'first activity')
    end

    it "should prepend the index to the description value" do
      expect( @activity.indexed_description ).to eq "1.1.1.1 first activity"
      @activity = Activity.create(:outcome_id => @outcome.id, :description => 'second activity')
      expect( @activity.indexed_description ).to eq "1.1.1.2 second activity"
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "second planned result")
      @outcome = Outcome.create(:planned_result_id => @planned_result.id, :description => "second outcome")
      @activity = Activity.create(:outcome_id => @outcome.id, :description => 'third activity')
      expect( @activity.indexed_description ).to eq "1.2.1.1 third activity"
    end
  end
end
