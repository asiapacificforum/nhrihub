class CorporateServices::StrategicPriorities::PlannedResultsController < CorporateServicesController
  def create
    super( PlannedResult.new(planned_result_params) )
  end

  def destroy
    super( PlannedResult )
  end

  def update
    planned_result = PlannedResult.find(params[:id])
    if planned_result.update_attributes(planned_result_params)
      render :json => planned_result.to_json, :status => 200
    else
      head :internal_server_error
    end
  end

  private
  def planned_result_params
    params.require(:planned_result).permit(:description, :strategic_priority_id, :outcomes_attributes => [:description, :id])
  end

end
