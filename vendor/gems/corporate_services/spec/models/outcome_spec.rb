require 'rails_helper'

describe "#indexed_description" do
  context "for the first in the planned result" do
    before do
      stp = StrategicPlan.create(:start_date => 6.months.ago.to_date )
      @sp = StrategicPriority.create(:description => 'first strategic priority', :priority_level => 1, :strategic_plan_id => stp.id)
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "first planned result")
      @outcome = Outcome.create(:planned_result_id => @planned_result.id, :description => "first outcome")
    end

    it "should prepend the index to the description value" do
      expect( @outcome.indexed_description ).to eq "1.1.1 first outcome"
      @outcome = Outcome.create(:planned_result_id => @planned_result.id, :description => "second outcome")
      expect( @outcome.indexed_description ).to eq "1.1.2 second outcome"
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "second planned result")
      @outcome = Outcome.create(:planned_result_id => @planned_result.id, :description => "third outcome")
      expect( @outcome.indexed_description ).to eq "1.2.1 third outcome"
    end
  end
end
