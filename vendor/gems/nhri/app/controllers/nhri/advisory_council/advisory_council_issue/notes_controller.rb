require 'notes_controller'

class Nhri::AdvisoryCouncil::AdvisoryCouncilIssue::NotesController < NotesController
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
    params[:note][:notable_id] = params[:advisory_council_issue_id]
    params[:note][:notable_type] = "Nhri::AdvisoryCouncil::AdvisoryCouncilIssue"
    super
  end
end
