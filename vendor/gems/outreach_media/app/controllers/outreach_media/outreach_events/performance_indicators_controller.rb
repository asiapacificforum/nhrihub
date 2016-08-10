class OutreachMedia::OutreachEvents::PerformanceIndicatorsController < ApplicationController
  def destroy
    pi = OutreachEventPerformanceIndicator.find(params[:id])
    pi.destroy
    render :json => pi, :status => 200
  end
end

