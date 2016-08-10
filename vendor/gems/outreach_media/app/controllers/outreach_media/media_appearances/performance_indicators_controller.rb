class OutreachMedia::MediaAppearances::PerformanceIndicatorsController < ApplicationController
  def destroy
    pi = MediaAppearancePerformanceIndicator.find_by(:media_appearance_id => params[:media_appearance_id], :performance_indicator_id => params[:id])
    pi.destroy
    render :json => pi, :status => 200
  end
end

