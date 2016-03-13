class Nhri::Indicator::IndicatorsController < ApplicationController
  def show
    @indicator = Nhri::Indicator::Indicator.find(params[:id])
    @heading = @indicator.heading
    @offence = @indicator.offence ? @indicator.offence.description : "all"
  end

  def destroy
    indicator = Nhri::Indicator::Indicator.find(params[:id])
    if indicator.destroy
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end
end
