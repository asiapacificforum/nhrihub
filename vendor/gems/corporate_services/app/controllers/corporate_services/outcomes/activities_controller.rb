class CorporateServices::Outcomes::ActivitiesController < ApplicationController
  def create
    activity = Activity.new(activity_params)
    if activity.save
      activities = activity.all_in_outcome
      render :json => activities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    activity = Activity.find(params[:id])
    outcome = activity.outcome
    if activity.destroy
      render :json => outcome.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    activity = Activity.find(params[:id])
    if activity.update_attributes(activity_params)
      strategic_priorities = activity.outcome.planned_result.strategic_priority.strategic_plan.strategic_priorities
      render :json => strategic_priorities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def activity_params
    params.require(:activity).permit(:description, :outcome_id, :performance_indicator, :target, :progress)
  end

end
