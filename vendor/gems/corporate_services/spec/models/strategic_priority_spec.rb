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
      StrategicPriority.create!(:priority_level => 1, :description => "blah blah blah", :strategic_plan_id => @sp.id)
      StrategicPriority.create!(:priority_level => 2, :description => "blah blah bloo", :strategic_plan_id => @sp.id)
      StrategicPriority.create!(:priority_level => 3, :description => "blah blah blank", :strategic_plan_id => @sp.id)
    end

    it "should increment the priority level of the existing strategic priority with lower priority" do
      StrategicPriority.create!(:priority_level => 2, :description => "bish bash bosh", :strategic_plan_id => @sp.id)

      expect(StrategicPriority.count).to eq 4
      expect(StrategicPriority.all.sort[0].priority_level).to eq 1
      expect(StrategicPriority.all.sort[0].description).to eq "blah blah blah"
      expect(StrategicPriority.all.sort[1].priority_level).to eq 2
      expect(StrategicPriority.all.sort[1].description).to eq "bish bash bosh"
      expect(StrategicPriority.all.sort[2].priority_level).to eq 3
      expect(StrategicPriority.all.sort[2].description).to eq "blah blah bloo"
      expect(StrategicPriority.all.sort[3].priority_level).to eq 4
      expect(StrategicPriority.all.sort[3].description).to eq "blah blah blank"
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

    it "should increment the priority level of the existing strategic priority" do
      StrategicPriority.create!(:priority_level => 1, :description => "bish bash bosh", :strategic_plan_id => @sp1.id)

      expect(StrategicPriority.count).to eq 2
      expect(StrategicPriority.all.last.priority_level).to eq 1
      expect(StrategicPriority.all.last.description).to eq "bish bash bosh"
      expect(StrategicPriority.all.first.priority_level).to eq 1
      expect(StrategicPriority.all.first.description).to eq "blah blah blah"
    end
  end # /context

end
