class CorporateServices::PlannedResults::OutcomesController < ApplicationController
  def create
    outcome = Outcome.new(outcome_params)
    if outcome.save
      render :json => outcome.to_json, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    outcome = Outcome.find(params[:id])
    if outcome.destroy
      render :json => Outcome.where(:planned_result_id => outcome.planned_result_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    outcome = Outcome.find(params[:id])
    if outcome.update_attributes(outcome_params)
      render :json => outcome.to_json, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def outcome_params
    params.require(:outcome).permit(:description, :planned_result_id)
  end
end
