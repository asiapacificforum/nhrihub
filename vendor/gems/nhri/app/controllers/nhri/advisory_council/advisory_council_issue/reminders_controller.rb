require 'reminders_controller'

class Nhri::AdvisoryCouncil::AdvisoryCouncilIssue::RemindersController < RemindersController
  # methods must be included here in order to control permissions
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  protected
  def reminder_params
    params[:reminder][:remindable_id] = params[:advisory_council_issue_id]
    params[:reminder][:remindable_type] = "Nhri::AdvisoryCouncil::AdvisoryCouncilIssue"
    super
  end
end

