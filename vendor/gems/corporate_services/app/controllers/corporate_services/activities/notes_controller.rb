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
    params.require(:note).permit(:text, :activity_id)
  end
end
