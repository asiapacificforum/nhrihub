class OutreachMedia::SubareasController < ApplicationController
  def create
    params[:subarea][:area_id] = params[:area_id]
    subarea = Subarea.new(subarea_params)
    if subarea.save
      render :json => Area.all
    else
      render :nothing => true, :status => 500
    end
  end


  private
  def subarea_params
    params.require('subarea').permit(:name, :area_id)
  end
end
