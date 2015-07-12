class StrategicPriority < ActiveRecord::Base
  belongs_to :strategic_plan
  has_many :planned_results, :dependent => :destroy, :autosave => true

  default_scope { order(:priority_level) }

  before_save do
    all_in_plan.
      select{|sp| (sp.id != id) && (sp.priority_level == priority_level)}.
      each{|sp| sp.increment!(:priority_level)}
  end

  def as_json(options={})
    super(:except => [:created_at, :updated_at],
          :methods => [:url, :create_planned_result_url, :planned_results] )
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_strategic_plan_strategic_priority_path(:en,strategic_plan_id,id)
  end

  def create_planned_result_url
    Rails.application.routes.url_helpers.corporate_services_strategic_priority_planned_results_path(:en,id)
  end

  def <=>(other)
    priority_level <=> other.priority_level
  end

  def all_in_plan
    strategic_plan.strategic_priorities.reload.sort
  end

end
