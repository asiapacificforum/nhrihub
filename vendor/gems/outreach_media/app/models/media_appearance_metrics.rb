class MediaAppearanceMetrics < Hash
  attr_accessor :source
  delegate :affected_people_count, :violation_severity, :violation_coefficient, :positivity_rating_rank, :to => :source

  def metric_name(key)
    I18n.t("activerecord.attributes.media_appearance."+key.to_s)
  end

  def metric_value(key)
    (send(key) || "N/A").to_s
  end

  def initialize(source)
    @source = source
    [:positivity_rating_rank, :violation_coefficient, :violation_severity, :affected_people_count].each do |key|
      super[metric_name(key)] = metric_value(key)
    end
  end
end
