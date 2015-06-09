class CorporateServices::StrategicPlansController < ApplicationController
  def show
    @strategic_plans = StrategicPlan.all_with_current.sort
    @strategic_plan = @strategic_plans.first
    @strategic_priority = StrategicPriority.new
    @strategic_priorities = StrategicPriority.all
  end
end
