class MediaAppearance::SubareasController < ApplicationController
  def create
    params[:subarea][:area_id] = params[:area_id]
    subarea = Subarea.new(subarea_params)
    if subarea.save
      render :json => Area.all
    else
      head :internal_server_error
    end
  end

  def destroy
    subarea = Subarea.find(params[:id])
    if subarea.destroy
      render :json => Area.all, :status => 200
    else
      head :internal_server_error
    end
  end

  private
  def subarea_params
    params.require('subarea').permit(:name, :area_id)
  end
end
