require 'reminders_controller'

class OutreachMedia::MediaAppearances::RemindersController < RemindersController
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
    params[:reminder][:remindable_id] = params[:media_appearance_id]
    params[:reminder][:remindable_type] = 'MediaAppearance'
    super
  end
end

