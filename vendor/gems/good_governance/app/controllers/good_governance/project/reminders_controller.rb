require 'reminders_controller'

class GoodGovernance::Project::RemindersController < RemindersController
  def update
    super
  end

  def create
    super
  end

  def destroy
    super
  end

  protected
  def reminder_params
    params[:reminder][:remindable_id] = params[:project_id]
    params[:reminder][:remindable_type] = 'GoodGovernance::Project'
    super
  end
end
