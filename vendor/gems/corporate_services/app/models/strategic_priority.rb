class StrategicPriority < ActiveRecord::Base
  belongs_to :strategic_plan

  default_scope { order(:priority_level) }

  before_save do
    all_in_plan.
      select{|sp| sp.priority_level == priority_level}.
      each{|sp| sp.increment!(:priority_level)}
  end

  def <=>(other)
    priority_level <=> other.priority_level
  end

  def all_in_plan
    strategic_plan.strategic_priorities.reload.sort
  end

end
