class ProjectsController < ApplicationController
  def create
    model = params[:project][:type].constantize
    project = model.new(project_params)
    if project.save
      render :json => project.to_json, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    project = Project.find(params[:id])
    if project.update(project_params)
      render :json => project.to_json, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    project = Project.find(params[:id])
    project.destroy
    render :nothing => true, :status => 200
  end

  private
  def project_params
    permitted_params = [:title,
                        :description,
                        :type,
                        :file,
                        :project_documents_attributes => [:file, :title, :filename, :original_type],
                        :mandate_ids => [],
                        :project_type_ids => [],
                        :agency_ids => [],
                        :convention_ids => [],
                        :performance_indicator_ids => []]
    params.require(:project).permit(*permitted_params)
  end
end
