class Reminder < ActiveRecord::Base
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  belongs_to :remindable, :polymorphic => true
  belongs_to :user
  default_scope ->{ order(:id) }

  scope :due_today, ->{ where("date(next) = ?", Time.now.utc.to_date) }

  # reminder_type => block passed to the date#advance method
  Increments = {
    'one-time'     => {},
    'daily'        => {:days => 1},
    'weekly'       => {:days  => 7},
    'monthly'      => {:months=> 1},
    'quarterly'    => {:months=> 3},
    'semi-annual'  => {:months=> 6},
    'annual'       => {:years => 1}
    }

  def as_json(options = {})
    super(:except => [:updated_at, :created_at], :methods => [ :recipient, :next_date, :previous_date, :user_id, :url, :start_year, :start_month, :start_day ])
  end

  before_save :calculate_next

  def next_or_today
    if self.next
      self.next.to_date
    else
      Date.today
    end
  end

  def start_year
    next_or_today.year
  end

  def start_month
    next_or_today.month
  end

  def start_day
    next_or_today.day
  end

  def url
    remindable.remindable_url(id)
  end

  def page_data
    remindable.page_data
  end

  def calculate_next
    date=start_date
    unless one_time?
      until(date.future?) do
        date = date.advance(increment)
      end
    end
    self.next = date.to_date.past? ? nil : date 
  end

  def one_time?
    reminder_type == "one-time"
  end

  # returns nil if one_time and start_date is in the future
  # returns nil if not one_time, but start_date is far enough in the future that
  # decrementing next is still in the future
  # otherwise returns a time object
  def previous
    if one_time? and start_date.past?
      previous = start_date
    elsif reminder_prior_to_next.past?
      previous = reminder_prior_to_next
    end
    previous
  end

  def previous_date
    unless self.previous.blank?
      self.previous.to_date.to_formatted_s(:short)
    else
      "none"
    end
  end

  def next_date
    if self.next
      self.next.to_date.to_formatted_s(:short)
    else
      "none"
    end
  end

  def recipient
    user
  end

  def self.send_reminders_due_today
    due_today.each(&:remind)
  end

  def remind
    ReminderMailer.reminder(self).deliver_now
    save # updates the next date
  end

  private
  def reminder_prior_to_next
    self.next.advance(decrement)
  end

  def increment
    Increments[reminder_type]
  end

  def decrement
    increment.blank? ? {} : {increment.keys.first => increment.values.first * -1}
  end

end
