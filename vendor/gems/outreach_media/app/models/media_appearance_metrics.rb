class MediaAppearanceMetrics < Array
  Metric=Struct.new(:name, :value)
  attr_accessor :source
  delegate :affected_people_count, :violation_severity, :violation_coefficient, :positivity_rating_rank, :to => :source

  def metrics
    [:positivity_rating_rank, :violation_coefficient, :violation_severity, :affected_people_count].collect { |key| metric(key) }
  end

  def metric(key)
    Metric.new(metric_name(key), metric_value(key))
  end

  def metric_name(key)
    I18n.t("activerecord.attributes.media_appearance."+key.to_s)
  end

  def metric_value(key)
    (send(key) || "N/A").to_s
  end

  def initialize(source)
    @source = source
    super(metrics)
  end
end
