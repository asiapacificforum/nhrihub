class CorporateServices::Activities::PerformanceIndicatorsController < CorporateServicesController
  def create
    super( PerformanceIndicator.new(performance_indicator_params) )
  end

  # response to destroy must be all remaining siblings due to re-indexing
  def destroy
    super PerformanceIndicator
  end

  def update
    performance_indicator = PerformanceIndicator.find(params[:id])
    if performance_indicator.update_attributes(performance_indicator_params)
      render :json => performance_indicator, :status => 200
    else
      head :internal_server_error
    end
  end

  private
  def performance_indicator_params
    params.require('performance_indicator').permit('activity_id','description','target')
  end
end
