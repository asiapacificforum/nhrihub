class OutreachMedia::MediaAppearances::RemindersController < ApplicationController
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
      render :json => reminder.page_data, :status => 200
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
    params[:reminder][:remindable_id] = params[:media_appearance_id]
    params[:reminder][:remindable_type] = 'MediaAppearance'
    params.require(:reminder).permit(:reminder_type, :start_date, :text, :remindable_id, :remindable_type, { :user_ids => [] })
  end
end

