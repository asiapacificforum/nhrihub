class GoodGovernance::ProjectsController < ApplicationController
  def index
    @projects = GoodGovernance::Project.all
    @mandates = Mandate.all
    @model_name = GoodGovernance::Project.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
    @agencies = Agency.all
    @conventions = Convention.all
    @planned_results = PlannedResult.all_with_associations
    # hard coded for now... it should be user-configurable
    @project_named_documents_titles = ["Project Document", "Analysis", "Final Report"]
    render 'projects/index'
  end
end
