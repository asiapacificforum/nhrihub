class CorporateServices::Activities::RemindersController < ApplicationController
  def create
    reminder = Reminder.new(reminder_params)
    if reminder.save
      puts Reminder.where(:activity_id => reminder.activity_id).to_json
      render :json => Reminder.where(:activity_id => reminder.activity_id), :status => 200
    else
      render :nothing => true, :status => 500
    end
  rescue => e # rescues strong parameter errors during development
    puts e
    render :nothing => true, :status => 500
  end

  private
  def reminder_params
    params.require(:reminder).permit(:reminder_type, :start_date, :text, :activity_id, { :user_ids => [] })
  end
end
