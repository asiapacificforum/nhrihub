class Outcome < ActiveRecord::Base
  include StrategicPlanIndex
  belongs_to :planned_result
  has_many :activities, :autosave => true, :dependent => :destroy

  def as_json(options={})
    super(:except => [:updated_at, :created_at],
          :methods => [:indexed_description, :description, :id, :url, :create_activity_url, :activities, :description_error])
  end

  def index_descendant
    activities
  end

  def index_parent
    planned_result
  end

  def description_error
    nil
  end

  def url
    Rails.application.routes.url_helpers.strategic_plans_planned_result_outcome_path(:en,planned_result_id,id)
  end

  def create_activity_url
    Rails.application.routes.url_helpers.strategic_plans_outcome_activities_path(:en,id)
  end

  def dup
    outcome = Outcome.new(attributes.slice("index", "description"))
    outcome.activities << activities.map(&:dup)
    outcome
  end

end
