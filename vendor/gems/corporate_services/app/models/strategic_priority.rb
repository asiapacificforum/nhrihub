class StrategicPriority < ActiveRecord::Base
  belongs_to :strategic_plan
  has_many :planned_results, :dependent => :destroy, :autosave => true

  default_scope { order(:priority_level) }

  before_create do
    siblings.
      select{|sp| sp.priority_level == priority_level}.
      each do |sp|
        priority_level = sp.priority_level
        sp.update_attribute(:priority_level, sp.priority_level.succ )
        sp.planned_results.each { |pr| pr.increment_index_root }
    end
  end

  before_update do
    siblings.
      select{|sp| (sp.id != id) && (sp.priority_level == priority_level)}.
      each do |sp|
        priority_level = sp.priority_level
        sp.update_attribute(:priority_level, sp.priority_level.succ )
        sp.planned_results.each { |pr| pr.increment_index_root }
    end
  end

  after_destroy do |strategic_priority|
    lower_priorities = StrategicPriority.where("priority_level > ? and strategic_plan_id = ?", strategic_priority.priority_level, strategic_priority.strategic_plan_id)
    lower_priorities.each{|sp| sp.decrement_priority_level}
  end

  def as_json(options={})
    super(:except => [:created_at, :updated_at],
          :methods => [:url, :planned_results, :description_error] )
  end

  def decrement_priority_level
    decrement!(:priority_level)
    planned_results.each{|pr| pr.decrement_index_prefix(priority_level)}
  end

  # for the purposes of StrategicPlanIndexer
  def index
    priority_level.to_s
  end

  def description_error
    nil
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_strategic_plan_strategic_priority_path(:en,strategic_plan_id,id)
  end

  def <=>(other)
    priority_level <=> other.priority_level
  end

  def siblings
    StrategicPriority.where(:strategic_plan_id => strategic_plan_id)
  end

  def dup
    strategic_priority = StrategicPriority.new(attributes.slice("priority_level", "description"))
    strategic_priority.planned_results << planned_results.map(&:dup)
    strategic_priority
  end

end
