class StrategicPlan < ActiveRecord::Base
  has_many :strategic_priorities

  def self.all_with_current
    ensure_current
    all.sort.reverse
  end

  def self.ensure_current
    unless all.any?(&:current?)
      create(:start_date => StrategicPlanStartDate.most_recent )
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
