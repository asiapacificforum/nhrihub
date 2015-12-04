class Activity < ActiveRecord::Base
  belongs_to  :outcome
  has_many :performance_indicators
  default_scope ->{ order(:id) } # this naturally orders by index

  # strip index if user has entered it
  before_save do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
  end

  def as_json(options={})
    super(:except =>  [:updated_at, :created_at],
          :methods => [:indexed_description,
                       :performance_indicators,
                       :url,
                       :description_error,
                       :reminders,
                       :create_reminder_url,
                       :create_performance_indicator_url,
                       :notes,
                       :create_note_url]
         )
  end

  def create_performance_indicator_url
    Rails.application.routes.url_helpers.corporate_services_activity_performance_indicators_path(:en,id)
  end

  def page_data
    outcome.planned_result.strategic_priority.strategic_plan.strategic_priorities
  end

  def namespace
    :corporate_services
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_outcome_activity_path(:en,outcome_id,id)
  end

  def description_error
    nil
  end

  def indexed_description
    if description.blank?
      ""
    else
      [index, description].join(' ')
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
