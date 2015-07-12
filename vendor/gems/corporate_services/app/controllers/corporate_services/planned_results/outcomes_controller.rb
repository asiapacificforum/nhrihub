class CorporateServices::PlannedResults::OutcomesController < ApplicationController
  def create
    outcome = Outcome.new(outcome_params)
    if outcome.save
      render :json => outcome.all_in_planned_result, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    outcome = Outcome.find(params[:id])
    planned_result = outcome.planned_result
    if outcome.destroy
      render :json => planned_result.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    outcome = Outcome.find(params[:id])
    if outcome.update_attributes(outcome_params)
      render :json => outcome.planned_result.strategic_priority.strategic_plan.strategic_priorities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def outcome_params
    params.require(:outcome).permit(:description, :planned_result_id)
  end
end
