class CorporateServices::StrategicPriorities::PlannedResultsController < ApplicationController
  def create
    planned_result = PlannedResult.new(planned_result_params)
    if planned_result.save
      # call to_json here b/c the built in call seems to supply unwanted options!
      render :json => planned_result.to_json, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    planned_result = PlannedResult.find(params[:id])
    if planned_result.destroy
      render :json => PlannedResult.where(:strategic_priority_id => planned_result.strategic_priority_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    planned_result = PlannedResult.find(params[:id])
    if planned_result.update_attributes(planned_result_params)
      render :json => planned_result.to_json, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def planned_result_params
    params.require(:planned_result).permit(:description, :strategic_priority_id, :outcomes_attributes => [:description, :id])
  end

end
