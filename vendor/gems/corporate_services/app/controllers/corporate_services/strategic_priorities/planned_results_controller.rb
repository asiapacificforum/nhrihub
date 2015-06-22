class CorporateServices::StrategicPriorities::PlannedResultsController < ApplicationController
  def create
    planned_result = PlannedResult.new(planned_result_params)
    if planned_result.save
      render :json => planned_result.all_in_strategic_priority, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def planned_result_params
    params.require(:planned_result).permit(:description, :strategic_priority_id)
  end

end
