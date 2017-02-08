class StrategicPlan < ActiveRecord::Base
  attr_accessor :copy
  has_many :strategic_priorities, :dependent => :destroy

  # an ActiveRecord::Relation is returned so that it can be merged, see PlannedResult.in_current_strategic_plan
  scope :current, ->{ where("strategic_plans.start_date >= ? and strategic_plans.start_date < ?",Date.today.advance(:years => -1),Date.today) }
  scope :eager_loaded_associations, ->{includes(:strategic_priorities => {:planned_results => {:outcomes => {:activities => {:performance_indicators => [:media_appearances, :projects, :notes, :reminders]}}}})}

  # leave this here as something to investigate in the future, At the moment it does not seem to improve
  # TTFB, but benchmark shows it's 10x faster than instantiating AR objects
  # it uses the surus gem, patched for has_many through associations
  def self.load_sql
    media_appearances = {:media_appearances => {:columns => [:title]}}
    projects = {:projects => {:columns => [:title]}}
    performance_indicators = {:performance_indicators => {:columns => [:id, :index, :description, :activity_id, :target, "concat(index,' ',description) indexed_description", "concat(index,' ',target) indexed_target"],
                                                          :include => [:notes, :reminders, projects, media_appearances] }}
    activities = {:activities => {:columns => [:id, :index, :description, :outcome_id, "concat(index,' ',description) indexed_description"],
                                  :include => performance_indicators}}
    outcomes = {:outcomes => {:columns => [:id, :description, :planned_result_id, :index, "concat(index, ' ', description) indexed_description"],
                              :include => activities }}
    planned_results = {:planned_results => {:columns => [:id, :description, :index, :strategic_priority_id, "concat(index, ' ', description) indexed_description"],
                                            :include => outcomes }}
    strategic_priorities = {:strategic_priorities => {:columns => [:id, :description, :priority_level, :strategic_plan_id],
                                                      :include => planned_results }}
    strategic_plan = {:columns => [:id, :start_date],
                      :include => strategic_priorities}
    all_json(strategic_plan)
  end

  def self.most_recent
    where("strategic_plans.created_at = (select max(created_at) from strategic_plans)").first
  end

  def initialize(attrs={})
    if attrs && (attrs.delete(:copy) == "true")
      initialize_with_copy(attrs)
    else
      super
    end
  end

  def initialize_with_copy(attrs)
    if StrategicPlan.count > 0
      attrs = attrs.merge(:strategic_priorities => StrategicPlan.most_recent.strategic_priorities.map(&:dup))
    end

    initialize( attrs)
  end

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => [:strategic_priorities,:current])
  end

  def current?
    self.id == StrategicPlan.most_recent.id
  end
  alias_method :current, :current?

  def <=>(other)
    created_at <=> other.created_at
  end
end
