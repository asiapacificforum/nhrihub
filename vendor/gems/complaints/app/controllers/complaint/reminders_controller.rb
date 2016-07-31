require 'reminders_controller'

class Complaint::RemindersController < RemindersController
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
    params[:reminder][:remindable_id] = params[:complaint_id]
    params[:reminder][:remindable_type] = 'Complaint'
    super
  end
end
