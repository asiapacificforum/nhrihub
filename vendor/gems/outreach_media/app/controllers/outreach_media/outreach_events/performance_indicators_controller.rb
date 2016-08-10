class OutreachMedia::OutreachEvents::PerformanceIndicatorsController < ApplicationController
  def destroy
    pi = OutreachEventPerformanceIndicator.find_by(:outreach_event_id => params[:outreach_event_id], :performance_indicator_id => params[:id])
    pi.destroy
    render :json => pi, :status => 200
  end
end

