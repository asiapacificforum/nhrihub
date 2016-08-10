class ProjectPerformanceIndicatorsController < ApplicationController
  def destroy
    ppi = ProjectPerformanceIndicator.find(params[:id])
    ppi.destroy
    render :json => ppi, :status => 200
  end
end
