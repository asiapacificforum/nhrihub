class CorporateServices::Activities::PerformanceIndicatorsController < ApplicationController
  def create
    performance_indicator = PerformanceIndicator.new(performance_indicator_params)
    if performance_indicator.save
      performance_indicators = performance_indicator.all_in_activity
      render :json => performance_indicators, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    performance_indicator = PerformanceIndicator.find(params[:id])
    activity = performance_indicator.activity
    if performance_indicator.destroy
      render :json => activity.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    performance_indicator = PerformanceIndicator.find(params[:id])
    if performance_indicator.update_attributes(performance_indicator_params)
      render :json => performance_indicator.activity.outcome.planned_result.strategic_priority.strategic_plan.strategic_priorities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def performance_indicator_params
    params.require('performance_indicator').permit('activity_id','description','target')
  end
end
