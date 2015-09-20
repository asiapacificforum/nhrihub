require 'notes_controller'

class CorporateServices::Activities::NotesController < NotesController
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
    params[:note][:notable_id] = params[:activity_id]
    params[:note][:notable_type] = "Activity"
    super
  end
end
