class StrategicPlans::StrategicPlan::StrategicPrioritiesController < StrategicPlanController
  def create
    strategic_priority = StrategicPriority.new(strategic_priority_params)
    if strategic_priority.save
      render :json => strategic_priority.siblings, :status => 200
    else
      head :internal_server_error
    end
  end

  def update
    strategic_priority = StrategicPriority.find(params[:id])
    if strategic_priority.update_attributes(strategic_priority_params)
      render :json => strategic_priority.siblings, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    super StrategicPriority
  end

  private
  def strategic_priority_params
    params[:strategic_priority][:strategic_plan_id] = params[:strategic_plan_id]
    params.require(:strategic_priority).permit(:priority_level, :description, :strategic_plan_id)
  end
end
