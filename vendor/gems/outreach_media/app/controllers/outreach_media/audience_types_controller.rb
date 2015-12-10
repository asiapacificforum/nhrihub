class OutreachMedia::AudienceTypesController < ApplicationController
  def create
    audience_type = AudienceType.new(audience_type_params)
    if audience_type.save
      render :json => audience_type, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    audience_type = AudienceType.find(params[:id])
    if audience_type.destroy
      render :json => {}, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def audience_type_params
    params.require(:audience_type).permit(:short_type, :long_type)
  end
end
