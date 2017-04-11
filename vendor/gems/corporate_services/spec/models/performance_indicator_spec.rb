require 'rails_helper'

describe "#indexed_description" do
  context "for the first in the outcome" do
    before do
      stp = StrategicPlan.create(:created_at => 6.months.ago.to_date )
      @sp = StrategicPriority.create(:description => 'first strategic priority', :priority_level => 1, :strategic_plan_id => stp.id)
      @planned_result = PlannedResult.create(:strategic_priority_id => @sp.id, :description => "first planned result")
      @outcome = Outcome.create(:planned_result_id => @planned_result.id, :description => "first outcome")
      @activity = Activity.create(:outcome_id => @outcome.id, :description => 'first activity')
      @performance_indicator = PerformanceIndicator.create(:activity_id => @activity.id, :description => 'first performance indicator')
    end

    it "should prepend the index to the description value" do
      expect(@performance_indicator.indexed_description).to eq "1.1.1.1.1 first performance indicator"
      @performance_indicator = PerformanceIndicator.create(:activity_id => @activity.id, :description => 'second performance indicator')
      expect(@performance_indicator.indexed_description).to eq "1.1.1.1.2 second performance indicator"
      @performance_indicator = PerformanceIndicator.create(:activity_id => @activity.id, :description => 'another second performance indicator')
      expect(@performance_indicator.indexed_description).to eq "1.1.1.1.3 another second performance indicator"
      @activity = Activity.create(:outcome_id => @outcome.id, :description => 'second activity')
      @performance_indicator = PerformanceIndicator.create(:activity_id => @activity.id, :description => 'third performance indicator')
      expect(@performance_indicator.indexed_description).to eq "1.1.1.2.1 third performance indicator"
    end
  end

  context "in a well-populated strategic plan" do
    before do
      spl = StrategicPlan.new
      spl.save
      sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan => spl)
      pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
      o = FactoryGirl.create(:outcome, :planned_result => pr)
      a1 = FactoryGirl.create(:activity, :outcome => o)
      2.times do
        FactoryGirl.create(:performance_indicator, :activity => a1)
      end
      a2 = FactoryGirl.create(:activity, :outcome => o)
      8.times do
        FactoryGirl.create(:performance_indicator, :activity => a2)
      end

      a1.performance_indicators << FactoryGirl.create(:performance_indicator, :activity => a1)
      a1.save
      @new_performance_indicator = a1.performance_indicators.to_a.last
    end

    it "should correctly assign the index" do
      expect(@new_performance_indicator.index).to eq "1.1.1.1.3"
    end
  end
end

describe "#lower_priority_siblings" do
  before do
    spl = StrategicPlan.new
    spl.save
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan => spl)
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
    o = FactoryGirl.create(:outcome, :planned_result_id => pr.id)
    a = FactoryGirl.create(:activity, :outcome_id => o.id)
    8.times do
      FactoryGirl.create(:performance_indicator, :activity_id => a.id)
    end
  end

  it "should identify lower priority siblings" do
    performance_indicator = PerformanceIndicator.where(:index => "1.1.1.1.4").first
    expect(performance_indicator.lower_priority_siblings.map(&:index)).to eq ["1.1.1.1.4","1.1.1.1.5","1.1.1.1.6","1.1.1.1.7","1.1.1.1.8"]
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

  context "when the highest planned result (lowest index) is deleted" do
    before do
      PerformanceIndicator.first.destroy
    end

    it "should decrement the performance_indicators indexes" do
      expect(PerformanceIndicator.pluck(:index)).to eq [ "1.1.1.1.1", "1.1.1.2.1", "1.1.1.2.2", "1.1.2.1.1", "1.1.2.1.2", "1.1.2.2.1", "1.1.2.2.2", "1.2.1.1.1", "1.2.1.1.2", "1.2.1.2.1", "1.2.1.2.2", "1.2.2.1.1", "1.2.2.1.2", "1.2.2.2.1", "1.2.2.2.2",
                                                         "2.1.1.1.1", "2.1.1.1.2", "2.1.1.2.1", "2.1.1.2.2", "2.1.2.1.1", "2.1.2.1.2", "2.1.2.2.1", "2.1.2.2.2", "2.2.1.1.1", "2.2.1.1.2", "2.2.1.2.1", "2.2.1.2.2", "2.2.2.1.1", "2.2.2.1.2", "2.2.2.2.1", "2.2.2.2.2"]
    end
  end
end
