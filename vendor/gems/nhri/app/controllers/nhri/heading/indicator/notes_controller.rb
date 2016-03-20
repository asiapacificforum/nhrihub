require 'notes_controller'

class Nhri::Heading::Indicator::NotesController < NotesController
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
    params[:note][:notable_id] = params[:indicator_id]
    params[:note][:notable_type] = 'Nhri::Indicator'
    super
  end
end
