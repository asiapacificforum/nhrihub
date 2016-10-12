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

describe "#indexed_description" do
  context "for the first in the planned result" do
    before do
      stp = StrategicPlan.create(:start_date => 6.months.ago.to_date )
      StrategicPriority.create(:description => 'first strategic priority', :priority_level => 1, :strategic_plan_id => stp.id)
      @sp = StrategicPriority.create(:description => 'first strategic priority', :priority_level => 2, :strategic_plan_id => stp.id)
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "first planned result")
    end

    it "should prepend the index to the description value" do
      expect( @planned_result.indexed_description ).to eq "2.1 first planned result"
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "second planned result")
      expect( @planned_result.indexed_description ).to eq "2.2 second planned result"
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
      PlannedResult.first.destroy
      @planned_result = PlannedResult.first # the NEW first planned_result
    end

    it "should decrement the planned_result index" do
      expect(PlannedResult.pluck(:index)).to eq ["1.1","2.1","2.2"]
    end

    it "should decrement the outcomes indexes" do
      expect(Outcome.pluck(:index)).to eq [ "1.1.1", "1.1.2", "2.1.1", "2.1.2", "2.2.1", "2.2.2"]
    end

    it "should decrement the activities indexes" do
      expect(Activity.pluck(:index)).to eq [ "1.1.1.1", "1.1.1.2", "1.1.2.1", "1.1.2.2", "2.1.1.1", "2.1.1.2", "2.1.2.1", "2.1.2.2", "2.2.1.1", "2.2.1.2", "2.2.2.1", "2.2.2.2"]
    end

    it "should decrement the performance_indicators indexes" do
      expect(PerformanceIndicator.pluck(:index)).to eq [ "1.1.1.1.1", "1.1.1.1.2", "1.1.1.2.1", "1.1.1.2.2", "1.1.2.1.1", "1.1.2.1.2", "1.1.2.2.1", "1.1.2.2.2",
                                                         "2.1.1.1.1", "2.1.1.1.2", "2.1.1.2.1", "2.1.1.2.2", "2.1.2.1.1", "2.1.2.1.2", "2.1.2.2.1", "2.1.2.2.2", "2.2.1.1.1", "2.2.1.1.2", "2.2.1.2.1", "2.2.1.2.2", "2.2.2.1.1", "2.2.2.1.2", "2.2.2.2.1", "2.2.2.2.2"]
    end
  end
end

describe ".all_with_associations scope" do
  before do
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year-1,1,1))
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan_id => previous_strategic_plan.id)
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
    @current_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year,1,1))
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan_id => @current_strategic_plan.id)
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
  end

  it "should include only planned results from current strategic plan" do
    expect(PlannedResult.all_with_associations.count).to eq 1
    expect(PlannedResult.all_with_associations.first.strategic_priority.strategic_plan).to eq @current_strategic_plan
  end
end
