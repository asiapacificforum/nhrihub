require 'strategic_plan'
class StrategicPlans::AdminController < ApplicationController
  def index
    @strategic_plan = StrategicPlan.new
    @strategic_plans = StrategicPlan.all.map{|sp| sp.attributes.slice("id", "title")}
    @delete_permitted = action_permitted?('strategic_plans/strategic_plan','destroy')
  end
end
