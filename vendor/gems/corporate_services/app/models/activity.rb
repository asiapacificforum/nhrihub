class Activity < ActiveRecord::Base
  include StrategicPlanIndex
  belongs_to  :outcome
  has_many :performance_indicators, :dependent => :destroy
  default_scope ->{ order(:index) }

  # strip index if user has entered it
  before_create do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
    self.index = StrategicPlanIndexer.create(self)
  end

  def as_json(options={})
    super(:except =>  [:updated_at, :created_at, :progress], #progress shouldn't even be in the schema!
          :methods => [:indexed_description,
                       :performance_indicators,
                       :url,
                       :description_error,
                       :create_performance_indicator_url]
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

  def index_descendant
    performance_indicators
  end

  def index_parent
    outcome
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_outcome_activity_path(:en,outcome_id,id)
  end

  def description_error
    nil
  end

  def copy
    activity = Activity.new(attributes.slice("index", "description"))
    activity.performance_indicators = performance_indicators.map(&:copy)
    activity
  end

end
