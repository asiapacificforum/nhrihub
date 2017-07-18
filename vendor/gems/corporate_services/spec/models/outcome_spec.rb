require 'rails_helper'

describe "#indexed_description" do
  context "for the first in the planned result" do
    before do
      stp = StrategicPlan.create(:created_at => 6.months.ago.to_date )
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

describe "#lower_priority_siblings" do
  before do
    spl = StrategicPlan.new
    spl.save
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan => spl)
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
    8.times do
      FactoryGirl.create(:outcome, :planned_result_id => pr.id)
    end
  end

  it "should identify lower priority siblings" do
    outcome = Outcome.where(:index => "1.1.4").first
    expect(outcome.lower_priority_siblings.map(&:index)).to eq ["1.1.4","1.1.5","1.1.6","1.1.7","1.1.8"]
  end
end

describe "destroy" do
  before do
    FactoryGirl.create(:strategic_plan, :well_populated)
  end

  it "should set the initial values of the indexes" do
    expect(PlannedResult.pluck(:index)).to eq ["1.1","1.2","2.1","2.2"]
    expect(Outcome.pluck(:index)).to eq [ "1.1.1", "1.1.2", "1.2.1", "1.2.2", "2.1.1", "2.1.2", "2.2.1", "2.2.2"]
    expect(Activity.pluck(:index)).to eq [ "1.1.1.1", "1.1.1.2", "1.1.2.1", "1.1.2.2", "1.2.1.1", "1.2.1.2", "1.2.2.1", "1.2.2.2", "2.1.1.1", "2.1.1.2", "2.1.2.1", "2.1.2.2", "2.2.1.1", "2.2.1.2", "2.2.2.1", "2.2.2.2"]
    expect(PerformanceIndicator.pluck(:index)).to eq [ "1.1.1.1.1", "1.1.1.1.2", "1.1.1.2.1", "1.1.1.2.2", "1.1.2.1.1", "1.1.2.1.2", "1.1.2.2.1", "1.1.2.2.2", "1.2.1.1.1", "1.2.1.1.2", "1.2.1.2.1", "1.2.1.2.2", "1.2.2.1.1", "1.2.2.1.2", "1.2.2.2.1", "1.2.2.2.2",
                                                       "2.1.1.1.1", "2.1.1.1.2", "2.1.1.2.1", "2.1.1.2.2", "2.1.2.1.1", "2.1.2.1.2", "2.1.2.2.1", "2.1.2.2.2", "2.2.1.1.1", "2.2.1.1.2", "2.2.1.2.1", "2.2.1.2.2", "2.2.2.1.1", "2.2.2.1.2", "2.2.2.2.1", "2.2.2.2.2"]
  end

  context "when the highest planned result is deleted" do
    before do
      Outcome.first.destroy
    end

    it "should decrement the outcomes indexes" do
      expect(Outcome.pluck(:index)).to eq [ "1.1.1", "1.2.1", "1.2.2", "2.1.1", "2.1.2", "2.2.1", "2.2.2"]
    end

    it "should decrement the activities indexes" do
      expect(Activity.pluck(:index)).to eq [ "1.1.1.1", "1.1.1.2", "1.2.1.1", "1.2.1.2", "1.2.2.1", "1.2.2.2", "2.1.1.1", "2.1.1.2", "2.1.2.1", "2.1.2.2", "2.2.1.1", "2.2.1.2", "2.2.2.1", "2.2.2.2"]
    end

    it "should decrement the performance_indicators indexes" do
      expect(PerformanceIndicator.pluck(:index)).to eq [ "1.1.1.1.1", "1.1.1.1.2", "1.1.1.2.1", "1.1.1.2.2", "1.2.1.1.1", "1.2.1.1.2", "1.2.1.2.1", "1.2.1.2.2", "1.2.2.1.1", "1.2.2.1.2", "1.2.2.2.1", "1.2.2.2.2",
                                                         "2.1.1.1.1", "2.1.1.1.2", "2.1.1.2.1", "2.1.1.2.2", "2.1.2.1.1", "2.1.2.1.2", "2.1.2.2.1", "2.1.2.2.2", "2.2.1.1.1", "2.2.1.1.2", "2.2.1.2.1", "2.2.1.2.2", "2.2.2.1.1", "2.2.2.1.2", "2.2.2.2.1", "2.2.2.2.2"]
    end
  end
end
