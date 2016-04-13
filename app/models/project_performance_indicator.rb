class ProjectPerformanceIndicator < ActiveRecord::Base
  belongs_to :project
  belongs_to :performance_indicator
end
