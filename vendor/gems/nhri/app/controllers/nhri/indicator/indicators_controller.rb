class Nhri::Indicator::IndicatorsController < ApplicationController
  def show
    @indicator = Nhri::Indicator::Indicator.find(params[:id])
    @heading = @indicator.heading
    @offence = @indicator.offence ? @indicator.offence.description : "all"
  end
end
