class ProjectsController < ApplicationController
  def index
    @projects = @model.all
    @mandates = Mandate.all
    @model_name = @model.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
    @agencies = Agency.all
    @conventions = Convention.all
    @planned_results = PlannedResult.all_with_associations
    @project_types = ProjectType.mandate_groups
    @project_named_documents_titles = ProjectDocument::NamedProjectDocumentTitles
    @maximum_filesize = ProjectDocument.maximum_filesize * 1000000
    @permitted_filetypes = ProjectDocument.permitted_filetypes.to_json
  end

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
