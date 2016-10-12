require 'rails_helper'

describe ".ensure_current" do
  context "when there is not a current strategic plan in the database" do
    it "should add a plan with today's date within its range" do
      expect{ StrategicPlan.ensure_current }.to change{ StrategicPlan.count }.from(0).to(1)
    end
  end

  context "when there is a current strategic plan in the database" do
    before do
      StrategicPlan.create(:start_date => 6.months.ago.to_date)
    end

    it "should not add a plan" do
      expect{ StrategicPlan.ensure_current }.not_to change{ StrategicPlan.count }
    end

  end

  context "when there is a non-current strategic plan in the database" do
    before do
      @previous_strategic_plan = FactoryGirl.create(:strategic_plan, :populated, :start_date => 13.months.ago.to_date)
      @strategic_priority = @previous_strategic_plan.strategic_priorities.first
      @planned_result = @strategic_priority.planned_results.first
      @outcome = @planned_result.outcomes.first
      @activity = @outcome.activities.first
      @performance_indicator = @activity.performance_indicators.first
      @strategic_plan = StrategicPlan.ensure_current
      @strategic_plan.reload
    end

    it "should add a plan" do
      expect(StrategicPlan.count).to eq 2
      expect(StrategicPlan.last.current?).to be true
    end

    context "when the most recent strategic plan is deleted" do # b/c there was a bug!
      before do
        StrategicPlan.current.first.destroy
      end

      it "should not change previous strategic plan associations" do
        expect(@previous_strategic_plan.strategic_priorities.map(&:priority_level).sort).to eq [1,2]
      end
    end

    it "should copy the associations" do
      strategic_priority = @strategic_plan.strategic_priorities.first
      expect( strategic_priority.priority_level ).to eq @strategic_priority.priority_level
      expect( strategic_priority.description ).to eq @strategic_priority.description
      expect( strategic_priority.id ).not_to eq @strategic_priority.id
      expect( strategic_priority.planned_results.length ).to eq @strategic_priority.planned_results.length
      expect( strategic_priority.persisted? ).to be true
      planned_result = strategic_priority.planned_results.first
      expect( planned_result.description ).to eq @planned_result.description
      expect( planned_result.index ).to eq @planned_result.index
      expect( planned_result.id ).not_to eq @planned_result.id
      expect( planned_result.outcomes.length ).to eq @planned_result.outcomes.length
      expect( planned_result.persisted? ).to be true
      outcome = planned_result.outcomes.first
      expect( outcome.description).to eq @outcome.description
      expect( outcome.index).to eq @outcome.index
      expect( outcome.id).not_to eq @outcome.id
      expect( outcome.activities.length ).to eq @outcome.activities.length
      expect( outcome.persisted? ).to be true
      activity = outcome.activities.first
      expect( activity.description ).to eq @activity.description
      expect( activity.index ).to eq @activity.index
      expect( activity.id ).not_to eq @activity.id
      expect( activity.performance_indicators.length ).to eq @activity.performance_indicators.length
      expect( activity.persisted? ).to be true
      performance_indicator = activity.performance_indicators.first
      expect( performance_indicator.description ).to eq @performance_indicator.description
      expect( performance_indicator.index ).to eq @performance_indicator.index
      expect( performance_indicator.target ).to eq @performance_indicator.target
      expect( performance_indicator.id ).not_to eq @performance_indicator.id
      expect( performance_indicator.persisted? ).to be true
    end
  end
end

describe ".current class method" do
  before do
    previous_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year-1,1,1))
    @current_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year,1,1))
  end

  it "should return the current strategic plan" do
    expect(StrategicPlan.current.first).to eq @current_strategic_plan
  end
end

describe ".most_recent" do
  before do
    @first_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year-1,1,1))
    @second_strategic_plan = FactoryGirl.create(:strategic_plan, :start_date => Date.new(Date.today.year,1,1))
  end

  it "should return the StrategicPlan instance with the most recent start_date" do
    expect(StrategicPlan.most_recent).to eq @second_strategic_plan
  end
end
