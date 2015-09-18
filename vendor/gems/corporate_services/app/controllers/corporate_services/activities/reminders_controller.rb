class CorporateServices::Activities::RemindersController < ApplicationController
  def create
    reminder = Reminder.new(reminder_params)
    if reminder.save
      render :json => Reminder.where(:remindable_id => reminder.remindable_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    reminder = Reminder.find(params[:id])
    if reminder.update_attributes(reminder_params)
      strategic_priorities = reminder.remindable.outcome.planned_result.strategic_priority.strategic_plan.strategic_priorities
      render :json => strategic_priorities, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    reminder = Reminder.find(params[:id])
    activity = reminder.remindable
    if reminder.destroy
      render :json => activity.reload, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def reminder_params
    params[:reminder][:remindable_id] = params[:activity_id]
    params[:reminder].delete(:activity_id)
    params[:reminder][:remindable_type] = 'Activity'
    params.require(:reminder).permit(:reminder_type, :start_date, :text, :remindable_id, :remindable_type, { :user_ids => [] })
  end
end
