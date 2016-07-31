class ProjectTypesController < ApplicationController
  def create
    project_type = @mandate.project_types.create(project_type_params)
    if project_type.errors.empty?
      render :text => project_type.name, :status => 200, :content_type => 'text/plain'
    else
      render :text => project_type.errors.full_messages.first, :status => 422
    end
  end

  def destroy
    project_type = @mandate.project_types.find_by(:name => params[:id])
    if project_type.destroy
      render :nothing => true, :status => 200
    else
      render :text => "something went wrong", :status => 500
    end
  end

  private
  def project_type_params
    params.require(:project_type).permit(:name)
  end
end
