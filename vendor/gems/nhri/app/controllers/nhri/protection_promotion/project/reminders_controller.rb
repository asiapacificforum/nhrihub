require 'reminders_controller'

class Nhri::ProtectionPromotion::Project::RemindersController < RemindersController
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
    params[:reminder][:remindable_type] = 'Project'
    super
  end
end
