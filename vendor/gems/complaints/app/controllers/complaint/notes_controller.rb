require 'notes_controller'

class Complaint::NotesController < NotesController
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
    params[:note][:notable_id] = params[:complaint_id]
    params[:note][:notable_type] = "Complaint"
    super
  end
end
