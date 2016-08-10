class MediaAppearancePerformanceIndicator < ActiveRecord::Base
  belongs_to :media_appearance
  belongs_to :performance_indicator

  def as_json(options={})
    super(:except => [:updated_at, :created_at, :media_appearance_id, :performance_indicator_id], :methods => [:association_id], :include => {:performance_indicator => {:only => [:id], :methods => [:indexed_description]}})
  end

  def association_id
    media_appearance_id
  end

  def association_id=(val)
    media_appearance_id=(val)
  end
end
