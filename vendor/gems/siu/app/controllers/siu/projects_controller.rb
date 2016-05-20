require 'project_document'

class Siu::ProjectsController < ApplicationController
  def index
    @projects = Siu::Project.all
    @mandates = Mandate.all
    @model_name = Siu::Project.to_s
    @i18n_key = @model_name.tableize.gsub(/\//,'.')
    @agencies = Agency.all
    @conventions = Convention.all
    @planned_results = PlannedResult.all_with_associations
    @project_types = ProjectType.mandate_groups
    @project_named_documents_titles = ProjectDocument::NamedProjectDocumentTitles
    @create_reminder_url = siu_project_reminders_path('en','id')
    @create_note_url     = siu_project_notes_path('en','id')
    @maximum_filesize = ProjectDocument.maximum_filesize * 1000000
    @permitted_filetypes = ProjectDocument.permitted_filetypes.to_json 
    render 'projects/index'
  end
end
