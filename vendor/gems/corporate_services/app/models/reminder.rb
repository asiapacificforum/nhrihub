class Reminder < ActiveRecord::Base
  belongs_to :remindable, :polymorphic => true
  has_and_belongs_to_many :users, :validate => false # we will only be adding/removing users by id, not changing their attributes. So performance is improved by not validating.
  default_scope ->{ order(:id) }

  def as_json(options = {})
    super(:except => [:updated_at, :created_at], :methods => [ :recipients, :next, :previous, :user_ids, :url, :start_year, :start_month, :start_day ])
  end

  def start_year
    if send(:next) == "none"
      Date.today.strftime("%Y")
    else
      send(:next).split(', ')[1]
    end
  end

  def start_month
    if send(:next) == "none"
      month = Date.today.strftime("%b")
    else
      month = send(:next).split(' ')[0]
    end
    Date::ABBR_MONTHNAMES.index(month)
  end

  def start_day
    if send(:next) == "none"
      Date.today.strftime("%e")
    else
      send(:next).split(",")[0].split(" ")[1]
    end
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_activity_reminder_path(:en,remindable_id,id)
  end

  def next
    if one_time? && start_date.future?
      date = start_date
    elsif !one_time?
      date = @next || next_reminder_date
    end

    if date
      date.to_formatted_s(:short)
    else
      "none"
    end
  end

  def one_time?
    reminder_type == "one-time"
  end

  def previous
    if start_date.future?
      "none"
    else
      previous_reminder_date.to_formatted_s(:short)
    end
  end

  def recipients
    users
  end

  private
  def next_reminder_date
    date=start_date
    unless one_time?
      until(date.future?) do
        date = date.advance(increment)
      end
    end
    @next = date
  end

  def previous_reminder_date
    next_date = @next || next_reminder_date
    next_date.advance(decrement)
  end

  def increment
    case reminder_type
    when 'weekly'
      {:days => 7}
    when 'monthly'
      {:months => 1}
    when 'quarterly'
      {:months => 3}
    when 'semi-annually'
      {:months => 6}
    when 'annually'
      {:years => 1}
    when 'one-time'
      {}
    end
  end

  def decrement
    increment.blank? ? {} : {increment.keys.first => increment.values.first * -1}
  end

end
