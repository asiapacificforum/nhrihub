class NotesController < ApplicationController
  def create
    note = Note.new(note_params)
    note.author = note.editor = current_user
    if note.save
      render :json => Note.where(:activity_id => note.activity_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  rescue => e # rescues strong parameter errors during development
    puts e
    render :nothing => true, :status => 500
  end

  def update
    note = Note.find(params[:id])
    note.editor = current_user
    if note.update_attributes(note_params)
      strategic_priorities = note.activity.outcome.planned_result.strategic_priority.strategic_plan.strategic_priorities
      render :json => strategic_priorities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    note = Note.find(params[:id])
    activity = note.activity
    if note.destroy
      render :json => activity.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def note_params
    params.require(:note).permit(:text, :activity_id)
  end
end
