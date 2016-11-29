require 'notes_controller'

class MediaAppearance::NotesController < NotesController
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
    params[:note][:notable_id] = params[:media_appearance_id]
    params[:note][:notable_type] = "MediaAppearance"
    super
  end
end
