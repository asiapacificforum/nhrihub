class Nhri::Heading::Indicator::MonitorsController < ApplicationController
  def create
    monitor = Nhri::Monitor.new(monitor_params)
    monitor.author = current_user
    if monitor.save
      render :json => Nhri::Monitor.where(:indicator_id => monitor.indicator_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    monitor = Nhri::Monitor.find(params[:id])
    if monitor.update_attributes(monitor_params)
      render :json => monitor, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    monitor = Nhri::Monitor.find(params[:id])
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
    params.require(:monitor).permit(:description, :date, :indicator_id)
  end
end
