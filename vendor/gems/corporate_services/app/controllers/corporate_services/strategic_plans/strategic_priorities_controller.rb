class CorporateServices::StrategicPlans::StrategicPrioritiesController < ApplicationController
  def create
    strategic_priority = StrategicPriority.create!(strategic_priority_params)
    render :json => strategic_priority, :status => 200
  rescue
    render :nothing => true, :status => 500
  end

  private
  def strategic_priority_params
    params[:strategic_priority][:strategic_plan_id] = params[:strategic_plan_id]
    params.require(:strategic_priority).permit(:priority_level, :description, :strategic_plan_id)
  end
end
