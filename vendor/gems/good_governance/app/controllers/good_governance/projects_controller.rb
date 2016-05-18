require 'project_document'

class GoodGovernance::ProjectsController < ApplicationController
  def index
    @projects = GoodGovernance::Project.all
    @mandates = Mandate.all
    @model_name = GoodGovernance::Project.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
    @agencies = Agency.all
    @conventions = Convention.all
    @planned_results = PlannedResult.all_with_associations
    @project_types = ProjectType.mandate_groups
    # TODO hard coded for now... it should be user-configurable eventually?
    # maybe at that point make ProjectDocument inherit from InternalDocument?
    # Then thse titles become document group titles
    @project_named_documents_titles = ProjectDocument::NamedProjectDocumentTitles
    @maximum_filesize = ProjectDocument.maximum_filesize * 1000000
    @permitted_filetypes = ProjectDocument.permitted_filetypes.to_json 
    render 'projects/index'
  end
end
