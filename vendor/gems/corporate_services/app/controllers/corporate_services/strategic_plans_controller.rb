class CorporateServices::StrategicPlansController < ApplicationController
  def show
    @strategic_plans = StrategicPlan.all_with_current.sort # for the select box options
    @strategic_priority = StrategicPriority.new
    if params[:id] == "current"
      @strategic_plan = @strategic_plans.last # the current strategic plan
    else
      @strategic_plan = StrategicPlan.find(params[:id])
    end
    @strategic_priorities = @strategic_plan.strategic_priorities
    respond_to do |format|
      format.html
      format.json {render :json => @strategic_plan.to_json(:only => :id, :methods => :strategic_priorities)}
    end
  end
end
