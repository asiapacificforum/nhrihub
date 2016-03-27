class Nhri::Indicator::MonitorsController < ApplicationController
  def create
    monitor = model.new(monitor_params)
    monitor.author = current_user
    if monitor.save
      render :json => monitor.indicator.monitors, :status => 200
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
    if monitor.destroy
      render :json => monitor.indicator.monitors, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def monitor_params
    params[:monitor][:indicator_id] = params[:indicator_id]
    params.require(:monitor).permit(*permitted_attributes)
  end

  def model
    (@model ||= "Nhri::"+params[:monitor].delete(:type)).constantize
  end

  def permitted_attributes
    (model.to_s+"::PermittedAttributes").constantize
  end
end
