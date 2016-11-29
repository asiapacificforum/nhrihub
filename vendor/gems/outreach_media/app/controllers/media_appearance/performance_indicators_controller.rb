class MediaAppearance::PerformanceIndicatorsController < ApplicationController
  def destroy
    pi = MediaAppearancePerformanceIndicator.find(params[:id])
    pi.destroy
    render :json => pi, :status => 200
  end
end

