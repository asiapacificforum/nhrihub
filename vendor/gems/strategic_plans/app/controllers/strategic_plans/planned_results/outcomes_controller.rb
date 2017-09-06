class StrategicPlans::PlannedResults::OutcomesController < StrategicPlanController
  def create
    super( Outcome.new(outcome_params) )
  end

  def destroy
    super Outcome
  end

  def update
    outcome = Outcome.find(params[:id])
    if outcome.update_attributes(outcome_params)
      render :json => outcome.to_json, :status => 200
    else
      head :internal_server_error
    end
  end

  private
  def outcome_params
    params.require(:outcome).permit(:description, :planned_result_id)
  end
end
