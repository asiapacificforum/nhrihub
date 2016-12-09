class Assign < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :assignee, :class_name => 'User', :foreign_key => :user_id

  # most recent first
  default_scope -> { order(:created_at => :desc)}

  after_create :notify_assignee

  def notify_assignee
    assignee.complaint_assignment_notify(complaint)
  end

  def as_json(options = {})
    super(:only => [], :methods => [:date, :name])
  end

  def date
    created_at.localtime.to_date.to_s(:short)
  end

  def name
    assignee.first_last_name
  end
end
