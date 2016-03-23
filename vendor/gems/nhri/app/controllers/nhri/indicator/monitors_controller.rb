class Nhri::Indicator::MonitorsController < ApplicationController
  def create
    monitor = model.new(monitor_params)
    monitor.author = current_user
    if monitor.save
      render :json => model.where(:indicator_id => monitor.indicator_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    monitor = model.find(params[:id])
    if monitor.update_attributes(monitor_params)
      render :json => monitor, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    monitor = model.find(params[:id])
    indicator = monitor.indicator
    if monitor.destroy
      render :json => indicator.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def monitor_params
    params[:monitor][:indicator_id] = params[:indicator_id]
    case @model.to_s
    when 'Nhri::NumericMonitor'
      params.require(:monitor).permit(:value, :date, :indicator_id)
    else
      raise "unknown model error"
    end
  end

  def model
    @model ||= ("Nhri::"+params[:monitor].delete(:type)).constantize
  end
end
