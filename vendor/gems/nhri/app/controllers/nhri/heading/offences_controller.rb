class Nhri::Heading::OffencesController < ApplicationController
  def create
    offence = Nhri::Offence.new(offence_params)
    if offence.save
      render :json => offence, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    offence = Nhri::Offence.find(params[:id])
    if offence.update_attributes(offence_params)
      render :json => offence, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    offence = Nhri::Offence.find(params[:id])
    if offence.destroy
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def offence_params
    params[:offence][:heading_id]=params[:heading_id]
    params.require(:offence).permit(:heading_id, :description)
  end
end
