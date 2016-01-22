class CorporateServices::Activities::PerformanceIndicatorsController < ApplicationController
  def create
    performance_indicator = PerformanceIndicator.new(performance_indicator_params)
    if performance_indicator.save
      render :json => performance_indicator, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  # response to destroy must be all remaining siblings due to re-indexing
  def destroy
    performance_indicator = PerformanceIndicator.find(params[:id])
    if performance_indicator.destroy
      render :json => PerformanceIndicator.where(:activity_id => performance_indicator.activity_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    performance_indicator = PerformanceIndicator.find(params[:id])
    if performance_indicator.update_attributes(performance_indicator_params)
      render :json => performance_indicator, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def performance_indicator_params
    params.require('performance_indicator').permit('activity_id','description','target')
  end
end
