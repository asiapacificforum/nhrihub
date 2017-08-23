class Activity < ActiveRecord::Base
  include StrategicPlanIndex
  belongs_to  :outcome
  has_many :performance_indicators, :dependent => :destroy

  def as_json(options={})
    super(:except =>  [:updated_at, :created_at, :progress], #progress shouldn't even be in the schema!
          :methods => [:indexed_description,
                       :performance_indicators,
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

  def index_descendant
    performance_indicators
  end

  def index_parent
    outcome
  end

  def description_error
    nil
  end

  def dup
    activity = Activity.new(attributes.slice("index", "description"))
    activity.performance_indicators = performance_indicators.map(&:dup)
    activity
  end

end
