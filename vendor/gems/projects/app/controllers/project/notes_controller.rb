require 'notes_controller'

class Project::NotesController < NotesController
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  private
  def note_params
    params[:note][:notable_id] = params[:project_id]
    params[:note][:notable_type] = "Project"
    super
  end
end
