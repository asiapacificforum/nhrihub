class StrategicPlanController < ApplicationController
  def create(model)
    if model.save
      render :json => model.as_json, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy(klass)
    model = klass.find(params[:id])
    if model.destroy
      render :json => model.siblings, :status => 200
    else
      head :internal_server_error
    end
  end
end
