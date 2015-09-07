class OutreachMedia::AreasController < ApplicationController
  def create
    area = Area.new(area_params)
    if area.save
      render :json => area, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end


  private
  def area_params
    params.require('area').permit(:name)
  end
end
