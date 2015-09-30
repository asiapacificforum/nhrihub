class MediaAppearanceMetrics < Hash
  attr_accessor :source
  delegate :affected_people_count, :violation_severity_rank, :violation_coefficient, :positivity_rating_rank, :to => :source

  def metric_name(key)
    I18n.t("activerecord.attributes.media_appearance."+key.to_s)
  end

  def initialize(source)
    @source = source
    [:positivity_rating_rank, :violation_coefficient, :violation_severity_rank, :affected_people_count].each do |key|
      super[key] = {:name => metric_name(key), :value => send(key)}
    end
  end
end
