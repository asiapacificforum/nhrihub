class Reminder < ActiveRecord::Base
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers
  belongs_to :remindable, :polymorphic => true
  has_and_belongs_to_many :users, :validate => false # we will only be adding/removing users by id, not changing their attributes. So performance is improved by not validating.
  default_scope ->{ order(:id) }

  # include reminder when date in the application's timezone is equal to the
  # reminder's next value translated into the local timezone and converted to a date
  # to understand this very ugly time zone weirdness see http://stackoverflow.com/a/21278339/451893
  scope :due_today, ->{ where("date(next AT TIME ZONE 'utc' AT TIME ZONE '#{ActiveSupport::TimeZone::MAPPING[TIME_ZONE]}') = ?", Time.zone.now.to_date) }

  # reminder_type => block passed to the date#advance method
  Increments = {
    'one-time'     => {},
    'daily'        => {:days => 1},
    'weekly'       => {:days  => 7},
    'monthly'      => {:months=> 1},
    'quarterly'    => {:months=> 3},
    'semi-annual'=> {:months=> 6},
    'annual'     => {:years => 1}
    }

  def as_json(options = {})
    super(:except => [:updated_at, :created_at], :methods => [ :recipients, :next_date, :previous_date, :user_ids, :url, :start_year, :start_month, :start_day ])
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
    self.next = date unless date.to_date.past?
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

    #def previous.to_s
      #unless self.blank?
        #self.to_formatted_s(:short)
      #else
        #"none"
      #end
    #end

    previous
  end

  def previous_date
    unless self.previous.blank?
      self.previous.to_date.to_formatted_s(:short)
    else
      "none"
    end
  end

  #def next
    #next_reminder_date = read_attribute('next')

    #def next_reminder_date.to_s
      #if self
        #self.to_formatted_s(:short)
      #else
        #"none"
      #end
    #end

    #next_reminder_date
  #end

  def next_date
    if self.next
      self.next.to_date.to_formatted_s(:short)
    else
      "none"
    end
  end

  def recipients
    users.sort_by{|u| [u.lastName, u.firstName]}
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
