class ProjectPerformanceIndicator < ActiveRecord::Base
  belongs_to :project
  belongs_to :performance_indicator

  def as_json(options={})
    super(:except => [:updated_at, :created_at, :project_id, :performance_indicator_id], :methods => [:association_id], :include => {:performance_indicator => {:only => [:id], :methods => [:indexed_description]}})
  end

  #TODO just alias these methods
  def association_id
    project_id
  end

  def association_id=(val)
    project_id=(val)
  end
end
