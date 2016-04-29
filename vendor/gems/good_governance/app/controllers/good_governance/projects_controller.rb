class GoodGovernance::ProjectsController < ApplicationController
  def index
    @projects = GoodGovernance::Project.all
    @mandates = Mandate.all
    @model_name = GoodGovernance::Project.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
    @agencies = Agency.all
    @conventions = Convention.all
    @planned_results = PlannedResult.all_with_associations
    render 'projects/index'
  end
end
