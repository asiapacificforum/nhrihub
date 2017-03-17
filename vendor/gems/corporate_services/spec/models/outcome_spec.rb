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

describe "destroy" do
  before do
    spl = StrategicPlan.new
    spl.save
    2.times do |i|
      sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1, :strategic_plan => spl)
      2.times do
        pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
        2.times do
          o = FactoryGirl.create(:outcome, :planned_result => pr)
          2.times do
            a = FactoryGirl.create(:activity, :outcome => o)
            2.times do
              FactoryGirl.create(:performance_indicator, :activity => a)
            end
          end
        end
      end
    end
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
