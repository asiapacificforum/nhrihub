class StrategicPlans::Outcomes::ActivitiesController < StrategicPlanController
  def create
    super( Activity.new(activity_params) )
  end

  def destroy
    super Activity
  end

  def update
    activity = Activity.find(params[:id])
    if activity.update_attributes(activity_params)
      render :json => activity, :status => 200
    else
      head :internal_server_error
    end
  end

  private
  def activity_params
    params.require(:activity).permit(:description, :outcome_id, :performance_indicator, :target, :progress)
  end

end
