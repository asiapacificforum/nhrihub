class ProjectPerformanceIndicatorsController < ApplicationController
  def destroy
    ppi = ProjectPerformanceIndicator.find_by(:project_id => params[:project_id], :performance_indicator_id => params[:id])
    ppi.destroy
    render :json => ppi, :status => 200
  end
end
