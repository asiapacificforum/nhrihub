class OutreachMedia::AreasController < ApplicationController
  def create
    area = Area.new(area_params)
    if area.save
      render :json => Area.all, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    area = Area.find(params[:id])
    if area.destroy
      render :json => Area.all, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def area_params
    params.require('area').permit(:name)
  end
end
