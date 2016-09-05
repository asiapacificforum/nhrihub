class Reminder < ActiveRecord::Base
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  belongs_to :remindable, :polymorphic => true
  has_and_belongs_to_many :users, :validate => false # we will only be adding/removing users by id, not changing their attributes. So performance is improved by not validating.
  default_scope ->{ order(:id) }

  Increments = {
    'weekly'       => {:days  => 7},
    'monthly'      => {:months=> 1},
    'quarterly'    => {:months=> 3},
    'semi-annually'=> {:months=> 6},
    'annually'     => {:years => 1},
    'one-time'     => {}
    }

  def as_json(options = {})
    super(:except => [:updated_at, :created_at], :methods => [ :recipients, :next, :previous, :user_ids, :url, :start_year, :start_month, :start_day ])
  end

  before_save :calculate_next

  def start_year
    unless self.next
      Date.today.strftime("%Y")
    else
      self.next.to_date.year
    end
  end

  def start_month
    unless self.next
      month = Date.today.strftime("%b")
    else
      self.next.to_date.month
    end
    Date::ABBR_MONTHNAMES.index(month)
  end

  def start_day
    unless self.next
      month = Date.today.strftime("%b")
      Date.today.strftime("%e")
    else
      self.next.to_date.day
    end
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
    self.next = date unless date.past?
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

    def previous.to_s
      unless self.blank?
        self.to_formatted_s(:short)
      else
        "none"
      end
    end

    previous
  end

  def next
    next_reminder_date = read_attribute('next')

    def next_reminder_date.to_s
      if self
        self.to_formatted_s(:short)
      else
        "none"
      end
    end

    next_reminder_date
  end

  def recipients
    users
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
