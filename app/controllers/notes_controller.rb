class NotesController < ApplicationController
  def create
    note = Note.new(note_params)
    note.author = note.editor = current_user
    if note.save
      render :json => note.siblings, :status => 200
    else
      head :internal_server_error
    end
  end

  def update
    note = Note.find(params[:id])
    note.editor = current_user
    if note.update_attributes(note_params)
      render :json => note, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    note = Note.find(params[:id])
    if note.destroy
      # TODO why can't we just return status 410 ?
      render :json => note.siblings, :status => 200
    else
      head :internal_server_error
    end
  end

  private
  def note_params
    params.require(:note).permit(:text, :editor_id, :author_id, :notable_id, :notable_type)
  end
end
