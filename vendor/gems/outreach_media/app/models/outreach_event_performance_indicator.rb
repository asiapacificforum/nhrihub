class OutreachEventPerformanceIndicator < ActiveRecord::Base
  belongs_to :outreach_event
  belongs_to :performance_indicator
end
