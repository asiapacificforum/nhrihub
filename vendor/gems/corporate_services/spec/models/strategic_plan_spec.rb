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
end
