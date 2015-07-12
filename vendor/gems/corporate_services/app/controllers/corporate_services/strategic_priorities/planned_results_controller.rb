class CorporateServices::StrategicPriorities::PlannedResultsController < ApplicationController
  def create
    planned_result = PlannedResult.new(planned_result_params)
    if planned_result.save
      render :json => planned_result.all_in_strategic_priority, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    planned_result = PlannedResult.find(params[:id])
    if planned_result.destroy
      render :json => planned_result.all_in_strategic_priority, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    planned_result = PlannedResult.find(params[:id])
    if planned_result.update_attributes(planned_result_params)
      render :json => planned_result.strategic_priority.strategic_plan.strategic_priorities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def planned_result_params
    params.require(:planned_result).permit(:description, :strategic_priority_id, :outcomes_attributes => [:description, :id])
  end

end
