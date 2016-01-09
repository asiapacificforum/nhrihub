require 'notes_controller'

class OutreachMedia::OutreachEvents::NotesController < NotesController
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
    params[:note][:notable_id] = params[:outreach_event_id]
    params[:note][:notable_type] = "OutreachEvent"
    super
  end
end
