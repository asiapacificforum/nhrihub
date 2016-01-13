require 'rails_helper'

describe "#indexed_description" do
  context "for the first in the strategic priority" do
    before do
      stp = StrategicPlan.create(:start_date => 6.months.ago.to_date )
      @sp = StrategicPriority.create(:description => 'first strategic priority', :priority_level => 1, :strategic_plan_id => stp.id)
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "first planned result")
    end

    it "should prepend the index to the description value" do
      expect( @planned_result.indexed_description ).to eq "1.1 first planned result"
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "second planned result")
      expect( @planned_result.indexed_description ).to eq "1.2 second planned result"
    end
  end

  context "for the second in the strategic priority" do
    before do
      stp = StrategicPlan.create(:start_date => 6.months.ago.to_date )
      sp = StrategicPriority.create(:description => 'first strategic priority', :priority_level => 1, :strategic_plan_id => stp.id)
      PlannedResult.create(:strategic_priority_id => sp.id, :description => "first planned result")
      @planned_result = PlannedResult.create(:strategic_priority_id => sp.id, :description => "second planned result")
    end

    it "should prepend the index to the description value" do
      expect( @planned_result.indexed_description ).to eq "1.2 second planned result"
    end
  end

  context "for the first in the strategic priority with priority level 2" do
    before do
      stp = StrategicPlan.create(:start_date => 6.months.ago.to_date )
      sp = StrategicPriority.create(:description => 'second strategic priority', :priority_level => 2, :strategic_plan_id => stp.id)
      PlannedResult.create(:strategic_priority_id => sp.id, :description => "first planned result")
      @planned_result = PlannedResult.create(:strategic_priority_id => sp.id, :description => "second planned result")
    end

    it "should prepend the index to the description value" do
      expect( @planned_result.indexed_description ).to eq "2.2 second planned result"
    end
  end

  context "when an index is mistakenly included in the description by the user" do
    before do
      stp = StrategicPlan.create(:start_date => 6.months.ago.to_date )
      sp = StrategicPriority.create(:description => 'second strategic priority', :priority_level => 2, :strategic_plan_id => stp.id)
      PlannedResult.create(:strategic_priority_id => sp.id, :description => "1.2  first planned result")
    end

    it "should strip the user-entered index" do
      expect(PlannedResult.first.description).to eq "first planned result"
    end
  end
end
