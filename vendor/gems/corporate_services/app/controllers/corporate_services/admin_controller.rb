class CorporateServices::AdminController < ApplicationController
  def index
    @strategic_plan = StrategicPlan.new
    @strategic_plans = StrategicPlan.select(:title, :id)
    @delete_permitted = action_permitted?('corporate_services/strategic_plans','destroy')
  end
end
