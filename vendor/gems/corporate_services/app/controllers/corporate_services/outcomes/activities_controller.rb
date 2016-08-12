class CorporateServices::Outcomes::ActivitiesController < ApplicationController
  def create
    activity = Activity.new(activity_params)
    if activity.save
      render :json => activity, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    activity = Activity.find(params[:id])
    outcome = activity.outcome
    if activity.destroy
      render :json => Activity.where(:outcome_id => activity.outcome_id), :status => 200
    else
      head :internal_server_error
    end
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
