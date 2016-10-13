class StrategicPlan < ActiveRecord::Base
  has_many :strategic_priorities, :dependent => :destroy

  # an ActiveRecord::Relation is returned so that it can be merged, see PlannedResult.in_current_strategic_plan
  scope :current, ->{ where("strategic_plans.start_date >= ? and strategic_plans.start_date < ?",Date.today.advance(:years => -1),Date.today) }

  def self.all_with_current
    ensure_current
    all.sort.reverse
  end

  def self.most_recent
    where("strategic_plans.start_date = (select max(start_date) from strategic_plans)").first
  end

  def self.ensure_current
    last_strategic_plan = most_recent
    if last_strategic_plan.nil?
      create(:start_date => StrategicPlanStartDate.most_recent)
    elsif !last_strategic_plan.current?
      strategic_priorities = last_strategic_plan.strategic_priorities.map(&:copy)
      create(:start_date => StrategicPlanStartDate.most_recent,
             :strategic_priorities => strategic_priorities )
    end
  end

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => :strategic_priorities)
  end

  def current?
    date_range.include?(Date.today)
  end

  def <=>(other)
    start_date <=> other.start_date
  end

  def date_range
    start_date ... end_date
  end

  def end_date
    start_date.advance(:years => 1, :days => -1)
  end
end
