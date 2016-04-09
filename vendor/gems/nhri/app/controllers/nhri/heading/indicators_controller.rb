class Nhri::Heading::IndicatorsController < ApplicationController
  def show
    @indicator = Nhri::Indicator.find(params[:id])
    @heading = @indicator.heading
    @attribute = @indicator.attribute ? @indicator.attribute.description : "all"
  end

  def destroy
    indicator = Nhri::Indicator.find(params[:id])
    if indicator.destroy
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def create
    indicator = Nhri::Indicator.new(indicator_params)
    if indicator.save!
      render :json => indicator, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    indicator = Nhri::Indicator.find(params[:id])
    if indicator.update_attributes(indicator_params)
      render :json => indicator, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def indicator_params
    params.require(:indicator).permit(:numeric_monitor_explanation, :attribute_id, :title, :nature, :monitor_format, :heading_id)
  end
end
