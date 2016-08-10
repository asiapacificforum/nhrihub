class OutreachEventPerformanceIndicator < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :performance_indicator

  def as_json(options={})
    super(:except => [:updated_at, :created_at, :outreach_event_id, :performance_indicator_id], :methods => [:association_id], :include => {:performance_indicator => {:only => [:id], :methods => [:indexed_description]}})
  end

  def association_id
    outreach_event_id
  end

  def association_id=(val)
    outreach_event_id=(val)
  end
end
