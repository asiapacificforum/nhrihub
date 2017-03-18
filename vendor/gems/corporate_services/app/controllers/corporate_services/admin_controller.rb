class CorporateServices::AdminController < ApplicationController
  def index
    @strategic_plan = StrategicPlan.new
    @strategic_plans = StrategicPlan.all.map{|sp| sp.attributes.slice("id", "title")}
    @delete_permitted = action_permitted?('corporate_services/strategic_plans','destroy')
  end
end
