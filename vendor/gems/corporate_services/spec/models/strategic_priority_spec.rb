require 'rails_helper'

describe ".create!" do
  context "when there are no other strategic priorities for this strategic plan" do
    it "should save with the provided priority level" do
      sp = StrategicPlan.create()
      StrategicPriority.create!(:priority_level => 1, :description => "blah blah blah", :strategic_plan_id => sp.id)
      expect(StrategicPriority.count).to eq 1
      expect(StrategicPriority.first.priority_level).to eq 1
      expect(StrategicPriority.first.description).to eq "blah blah blah"
    end
  end

  context "when there is an existing strategic priority with the same priority level" do
    before do
      @sp = StrategicPlan.create()
      StrategicPriority.create!(:priority_level => 1, :description => "blah blah blah", :strategic_plan_id => @sp.id)
    end

    it "should increment the priority level of the existing strategic priority" do
      StrategicPriority.create!(:priority_level => 1, :description => "bish bash bosh", :strategic_plan_id => @sp.id)

      expect(StrategicPriority.count).to eq 2
      expect(StrategicPriority.all.sort.first.priority_level).to eq 1
      expect(StrategicPriority.all.sort.first.description).to eq "bish bash bosh"
      expect(StrategicPriority.all.sort.last.priority_level).to eq 2
      expect(StrategicPriority.all.sort.last.description).to eq "blah blah blah"
    end
  end # /context

  context "when there are existing strategic priorities with the various priority level" do
    before do
      @sp = StrategicPlan.create()
      FactoryGirl.create(:strategic_priority, :populated, :priority_level => 1, :description => "blah blah blah", :strategic_plan_id => @sp.id)
      FactoryGirl.create(:strategic_priority, :populated, :priority_level => 2, :description => "blah blah bloo", :strategic_plan_id => @sp.id)
      FactoryGirl.create(:strategic_priority, :populated, :priority_level => 3, :description => "blah blah blank", :strategic_plan_id => @sp.id)
    end

    it "should increment the priority level of the existing strategic priority with lower priority" do
      FactoryGirl.create(:strategic_priority, :populated, :priority_level => 2, :description => "bish bash bosh", :strategic_plan_id => @sp.id)

      expect(StrategicPriority.count).to eq 4
      expect(StrategicPriority.all.sort[0].priority_level).to eq 1
      expect(StrategicPriority.all.sort[0].description).to eq "blah blah blah"
      expect(StrategicPriority.all.sort[0].planned_results.sort[0].index).to eq "1.1"
      expect(StrategicPriority.all.sort[0].planned_results.sort[0].outcomes.sort[0].index).to eq "1.1.1"
      expect(StrategicPriority.all.sort[0].planned_results.sort[0].outcomes.sort[0].activities.sort[0].index).to eq "1.1.1.1"
      expect(StrategicPriority.all.sort[0].planned_results.sort[0].outcomes.sort[0].activities.sort[0].performance_indicators.sort[0].index).to eq "1.1.1.1.1"

      expect(StrategicPriority.all.sort[1].priority_level).to eq 2
      expect(StrategicPriority.all.sort[1].description).to eq "bish bash bosh"
      expect(StrategicPriority.all.sort[1].planned_results.sort[0].index).to eq "2.1"
      expect(StrategicPriority.all.sort[1].planned_results.sort[0].outcomes.sort[0].index).to eq "2.1.1"
      expect(StrategicPriority.all.sort[1].planned_results.sort[0].outcomes.sort[0].activities.sort[0].index).to eq "2.1.1.1"
      expect(StrategicPriority.all.sort[1].planned_results.sort[0].outcomes.sort[0].activities.sort[0].performance_indicators.sort[0].index).to eq "2.1.1.1.1"

      expect(StrategicPriority.all.sort[2].priority_level).to eq 3
      expect(StrategicPriority.all.sort[2].description).to eq "blah blah bloo"
      expect(StrategicPriority.all.sort[2].planned_results.sort[0].index).to eq "3.1"
      expect(StrategicPriority.all.sort[2].planned_results.sort[0].outcomes.sort[0].index).to eq "3.1.1"
      expect(StrategicPriority.all.sort[2].planned_results.sort[0].outcomes.sort[0].activities.sort[0].index).to eq "3.1.1.1"
      expect(StrategicPriority.all.sort[2].planned_results.sort[0].outcomes.sort[0].activities.sort[0].performance_indicators.sort[0].index).to eq "3.1.1.1.1"

      expect(StrategicPriority.all.sort[3].priority_level).to eq 4
      expect(StrategicPriority.all.sort[3].description).to eq "blah blah blank"
      expect(StrategicPriority.all.sort[3].planned_results.sort[0].index).to eq "4.1"
      expect(StrategicPriority.all.sort[3].planned_results.sort[0].outcomes.sort[0].index).to eq "4.1.1"
      expect(StrategicPriority.all.sort[3].planned_results.sort[0].outcomes.sort[0].activities.sort[0].index).to eq "4.1.1.1"
      expect(StrategicPriority.all.sort[3].planned_results.sort[0].outcomes.sort[0].activities.sort[0].performance_indicators.sort[0].index).to eq "4.1.1.1.1"
    end
  end # /context

  context "when there are existing strategic priorities with the non-sequential priority levels" do
    before do
      @sp = StrategicPlan.create()
      StrategicPriority.create!(:priority_level => 1, :description => "blah blah blah", :strategic_plan_id => @sp.id)
      StrategicPriority.create!(:priority_level => 3, :description => "blah blah bloo", :strategic_plan_id => @sp.id)
      StrategicPriority.create!(:priority_level => 5, :description => "blah blah blank", :strategic_plan_id => @sp.id)
    end

    it "should not increment the priority level of the existing strategic priorities if there is no conflict with the new priority_level" do
      StrategicPriority.create!(:priority_level => 2, :description => "bish bash bosh", :strategic_plan_id => @sp.id)

      expect(StrategicPriority.count).to eq 4
      expect(StrategicPriority.all.sort[0].priority_level).to eq 1
      expect(StrategicPriority.all.sort[0].description).to eq "blah blah blah"
      expect(StrategicPriority.all.sort[1].priority_level).to eq 2
      expect(StrategicPriority.all.sort[1].description).to eq "bish bash bosh"
      expect(StrategicPriority.all.sort[2].priority_level).to eq 3
      expect(StrategicPriority.all.sort[2].description).to eq "blah blah bloo"
      expect(StrategicPriority.all.sort[3].priority_level).to eq 5
      expect(StrategicPriority.all.sort[3].description).to eq "blah blah blank"
    end

    it "should increment existing strategic priorities only sufficient to resolve priority duplications" do
      StrategicPriority.create!(:priority_level => 1, :description => "bish bash bosh", :strategic_plan_id => @sp.id)

      expect(StrategicPriority.count).to eq 4
      expect(StrategicPriority.all.sort[0].priority_level).to eq 1
      expect(StrategicPriority.all.sort[0].description).to eq "bish bash bosh"
      expect(StrategicPriority.all.sort[1].priority_level).to eq 2
      expect(StrategicPriority.all.sort[1].description).to eq "blah blah blah"
      expect(StrategicPriority.all.sort[2].priority_level).to eq 3
      expect(StrategicPriority.all.sort[2].description).to eq "blah blah bloo"
      expect(StrategicPriority.all.sort[3].priority_level).to eq 5
      expect(StrategicPriority.all.sort[3].description).to eq "blah blah blank"
    end
  end # /context

  context "when there is an existing strategic priority with the same priority level in a different strategic plan" do
    before do
      @sp = StrategicPlan.create()
      StrategicPriority.create!(:priority_level => 1, :description => "blah blah blah", :strategic_plan_id => @sp.id)
      @sp1 = StrategicPlan.create()
    end

    it "should not increment the priority level of the existing strategic priority" do
      StrategicPriority.create!(:priority_level => 1, :description => "bish bash bosh", :strategic_plan_id => @sp1.id)

      expect(StrategicPriority.count).to eq 2
      expect(StrategicPriority.all.last.priority_level).to eq 1
      expect(StrategicPriority.all.first.priority_level).to eq 1
    end
  end # /context

  context "when updating a strategic priority description" do
    before do
      @sp = StrategicPlan.create()
      StrategicPriority.create!(:priority_level => 1, :description => "blah blah blah", :strategic_plan_id => @sp.id)
    end

    it "should leave the priority level unchanged" do
      StrategicPriority.first.update_attribute(:description, "bish bash bosh")
      expect(StrategicPriority.first.reload.priority_level).to eq 1
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

  context "when the highest strategic priority is deleted" do
    before do
      StrategicPriority.first.destroy
      @strategic_priority = StrategicPriority.first # the NEW first strategic_priority
    end

    it "should decrement all other strategic priorioty priority_level attributes" do
      expect(@strategic_priority.priority_level).to eq 1
    end

    it "should decrement the planned_result index" do
      expect(PlannedResult.pluck(:index)).to eq ["1.1","1.2"]
    end

    it "should decrement the outcomes indexes" do
      expect(Outcome.pluck(:index)).to eq ["1.1.1", "1.1.2", "1.2.1", "1.2.2"]
    end

    it "should decrement the activities indexes" do
      expect(Activity.pluck(:index)).to eq [ "1.1.1.1", "1.1.1.2", "1.1.2.1", "1.1.2.2", "1.2.1.1", "1.2.1.2", "1.2.2.1", "1.2.2.2" ]
    end

    it "should decrement the performance_indicators indexes" do
      expect(PerformanceIndicator.pluck(:index)).to eq [ "1.1.1.1.1", "1.1.1.1.2", "1.1.1.2.1", "1.1.1.2.2", "1.1.2.1.1", "1.1.2.1.2", "1.1.2.2.1", "1.1.2.2.2", "1.2.1.1.1", "1.2.1.1.2", "1.2.1.2.1", "1.2.1.2.2", "1.2.2.1.1", "1.2.2.1.2", "1.2.2.2.1", "1.2.2.2.2"]
    end
  end
end
