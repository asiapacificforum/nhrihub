class OutreachMedia::AreasController < ApplicationController
  def create
    area = Area.new(area_params)
    if area.save
      render :json => Area.all, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    area = Area.find(params[:id])
    if area.destroy
      render :json => Area.all, :status => 200
    else
      head :internal_server_error
    end
  end

  private
  def area_params
    params.require('area').permit(:name)
  end
end
