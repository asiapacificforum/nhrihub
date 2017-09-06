require 'rails_helper'

describe "#indexed_description" do
  context "for the first in the strategic priority" do
    before do
      stp = StrategicPlan.create(:created_at => 6.months.ago.to_date )
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
      stp = StrategicPlan.create(:created_at => 6.months.ago.to_date )
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
      stp = StrategicPlan.create(:created_at => 6.months.ago.to_date )
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
      stp = StrategicPlan.create(:created_at => 6.months.ago.to_date )
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
      stp = StrategicPlan.create(:created_at => 6.months.ago.to_date )
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

describe "#lower_priority_siblings" do
  before do
    spl = StrategicPlan.new
    spl.save
    2.times do |i|
      sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1, :strategic_plan => spl)
      8.times do
        pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
      end
    end
  end

  it "should idenify lower priority siblings" do
    planned_result = PlannedResult.where(:index => "1.4").first
    expect(planned_result.lower_priority_siblings.map(&:index)).to eq ["1.4","1.5","1.6","1.7","1.8"]
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
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :created_at => Date.new(Date.today.year-1,1,1))
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan_id => previous_strategic_plan.id)
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
    @current_strategic_plan = FactoryGirl.create(:strategic_plan, :created_at => Date.new(Date.today.year,1,1))
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan_id => @current_strategic_plan.id)
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
    o = FactoryGirl.create(:outcome, :planned_result => pr)
    a = FactoryGirl.create(:activity, :outcome => o)
    pi = FactoryGirl.create(:performance_indicator, :activity => a)
  end

  it "should include only planned results from current strategic plan" do
    expect(PlannedResult.all_with_associations.count).to eq 1
    expect(PlannedResult.all_with_associations.first.strategic_priority.strategic_plan).to eq @current_strategic_plan
  end

  it "should render to json with required planned_result options" do
    json = JSON.parse(PlannedResult.all_with_associations.to_json)
    expect(json[0].keys).to match_array ["indexed_description", "outcomes"]
    expect(json[0]["outcomes"][0].keys).to match_array ["indexed_description", "activities"]
    expect(json[0]["outcomes"][0]["activities"][0].keys).to match_array ["indexed_description", "performance_indicators"]
    expect(json[0]["outcomes"][0]["activities"][0]["performance_indicators"][0].keys).to match_array ["indexed_description", "id"]
  end
end

describe ".in_current_strategic_plan scope" do
  before do
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :created_at => Date.new(Date.today.year-1,1,1))
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan_id => previous_strategic_plan.id)
    pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
    @current_strategic_plan = FactoryGirl.create(:strategic_plan, :created_at => Date.new(Date.today.year,1,1))
    sp = FactoryGirl.create(:strategic_priority, :priority_level => 1, :strategic_plan_id => @current_strategic_plan.id)
    @pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
  end

  it "should include only planned results from current strategic plan" do
    expect(PlannedResult.in_current_strategic_plan.count).to eq 1
    expect(PlannedResult.in_current_strategic_plan.first).to eq @pr
  end
end
