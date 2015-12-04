class PerformanceIndicator < ActiveRecord::Base
  belongs_to :activity
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  default_scope ->{ order(:id) } # this naturally orders by index

  def as_json(options={})
    super(:except =>  [:updated_at, :created_at],
          :methods => [:indexed_description,
                       :url,
                       :indexed_target,
                       :description_error,
                       :reminders,
                       :create_reminder_url,
                       :notes,
                       :create_note_url]
         )
  end

  def namespace
    :corporate_services
  end

  def create_note_url
    Rails.application.routes.url_helpers.corporate_services_performance_indicator_notes_path(:en,id)
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.corporate_services_performance_indicator_reminders_path(:en,id)
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_activity_performance_indicator_path(:en,activity_id,id)
  end

  def description_error
    nil
  end

  #def indexed_performance_indicator
    #if performance_indicator.blank?
      #""
    #else
      #[index, performance_indicator].join(' ')
    #end
  #end

  def indexed_description
    if description.blank?
      ""
    else
      [index, description].join(' ')
    end
  end

  def index
    prefix = activity.index
    last_digit = all_in_activity.sort_by(&:id).index(self).succ.to_s
    [prefix, last_digit].join('.')
  end

  def indexed_target
    if target.blank?
      ""
    else
      [index, target].join(' ')
    end
  end

  def all_in_activity
    PerformanceIndicator.where(:activity_id => activity_id)
  end
end
