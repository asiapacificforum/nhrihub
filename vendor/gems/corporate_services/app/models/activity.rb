class Activity < ActiveRecord::Base
  belongs_to  :outcome
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :autosave => true, :dependent => :destroy
  default_scope ->{ order(:id) } # this naturally orders by index

  # strip index if user has entered it
  before_save do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
  end

  def as_json(options={})
    super(:except =>  [:updated_at, :created_at],
          :methods => [:indexed_description,
                       :description,
                       :indexed_performance_indicator,
                       :performance_indicator,
                       :target,
                       :indexed_target,
                       :id,
                       :url,
                       :description_error,
                       :progress,
                       :reminders,
                       :create_reminder_url,
                       :notes,
                       :create_note_url]
         )
  end

  def create_note_url
    Rails.application.routes.url_helpers.corporate_services_activity_notes_path(:en,id)
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.corporate_services_activity_reminders_path(:en,id)
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_outcome_activity_path(:en,outcome_id,id)
  end

  def description_error
    nil
  end

  def indexed_target
    if target.blank?
      ""
    else
      [index, target].join(' ')
    end
  end

  def indexed_description
    if description.blank?
      ""
    else
      [index, description].join(' ')
    end
  end

  def indexed_performance_indicator
    if performance_indicator.blank?
      ""
    else
      [index, performance_indicator].join(' ')
    end
  end

  def index
    prefix = outcome.index
    last_digit = all_in_outcome.sort_by(&:id).index(self).succ.to_s
    [prefix, last_digit].join('.')
  end

  def all_in_outcome
    Activity.where(:outcome_id => outcome_id)
  end
end
