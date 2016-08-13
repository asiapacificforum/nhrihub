class Activity < ActiveRecord::Base
  belongs_to  :outcome
  has_many :performance_indicators, :dependent => :destroy
  default_scope ->{ order(:index) }

  # strip index if user has entered it
  before_create do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
    self.index = StrategicPlanIndexer.new(self,outcome).next
  end

  def as_json(options={})
    super(:except =>  [:updated_at, :created_at],
          :methods => [:indexed_description,
                       :performance_indicators,
                       :url,
                       :description_error,
                       #:reminders, # shouldn't be here... didn't cause a problem until rails5
                       #:create_reminder_url,
                       :create_performance_indicator_url]
                       #:notes,
                       #:create_note_url]
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

  after_destroy do |activity|
    lower_indexes = Activity.
                      where(:outcome_id => activity.outcome_id).
                      select{|a| a >= self}
    lower_indexes.each{|a| a.decrement_index }
  end

  def <=>(other)
    self.index.split('.').map(&:to_i) <=> other.index.split('.').map(&:to_i)
  end

  def >=(other)
    [0,1].include?(self <=> other)
  end

  def decrement_index
    ar = index.split('.')
    new_suffix = ar.pop.to_i.pred.to_i
    ar << new_suffix
    new_index = ar.join('.')
    update_attribute(:index, ar.join('.'))
    performance_indicators.each{|o| o.decrement_index_prefix(new_index)}
  end

  def decrement_index_prefix(new_prefix)
    ar = index.split('.')
    new_index = [new_prefix,ar[3]].join('.')
    update_attribute(:index, new_index)
    performance_indicators.each{|o| o.decrement_index_prefix(new_index)}
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
end
