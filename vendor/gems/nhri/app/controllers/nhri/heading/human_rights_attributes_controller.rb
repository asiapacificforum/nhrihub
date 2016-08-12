class Nhri::Heading::HumanRightsAttributesController < ApplicationController
  def create
    attribute = Nhri::HumanRightsAttribute.new(attribute_params)
    if attribute.save
      render :json => attribute, :status => 200
    else
      head :internal_server_error
    end
  end

  def update
    attribute = Nhri::HumanRightsAttribute.find(params[:id])
    if attribute.update_attributes(attribute_params)
      render :json => attribute, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    attribute = Nhri::HumanRightsAttribute.find(params[:id])
    if attribute.destroy
      head :ok
    else
      head :internal_server_error
    end
  end

  private
  def attribute_params
    params[:human_rights_attribute][:heading_id]=params[:heading_id]
    params.require(:human_rights_attribute).permit(:heading_id, :description)
  end
end
