class Nhri::Indicator::FileMonitorsController < ApplicationController
  def create
    monitor = Nhri::FileMonitor.new(monitor_params)
    monitor.author = current_user
    if monitor.save
      render :json => monitor, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    monitor = Nhri::FileMonitor.find(params[:id])
    if monitor.update_attributes(monitor_params)
      render :json => monitor, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    monitor = Nhri::FileMonitor.find(params[:id])
    indicator = monitor.indicator
    if monitor.destroy
      render :json => indicator.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def show
    monitor = Nhri::FileMonitor.find(params[:id])
    response.headers['Content-Length'] = monitor.filesize.to_s
    send_opts = { :filename => monitor.original_filename,
                  :type => monitor.original_type,
                  :disposition => :attachment,
                  :x_sendfile => true }
    send_file monitor.file.to_io, send_opts
  end

  private
  def monitor_params
    params[:monitor][:indicator_id] = params[:indicator_id]
    params.require(:monitor).permit(*permitted_attributes)
  end

  def permitted_attributes
    Nhri::FileMonitor::PermittedAttributes
  end
end
