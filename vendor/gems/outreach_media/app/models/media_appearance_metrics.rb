class MediaAppearanceMetrics < Hash
  attr_accessor :source
  delegate :affected_people_count,
           :violation_coefficient,
           :violation_severity_id,
           :violation_severity_rank_text,
           :violation_severity,
           :positivity_rating_id,
           :positivity_rating_rank_text,
           :positivity_rating,
           :to => :source

  def metric_name(key)
    I18n.t("activerecord.attributes.media_appearance."+key.to_s)
  end

  def initialize(source)
    @source = source
    super[:positivity_rating] = {:name => metric_name(:positivity_rating), :value => send(:positivity_rating_rank_text), :id => send(:positivity_rating_id)}
    super[:violation_severity] = {:name => metric_name(:violation_severity), :value => send(:violation_severity_rank_text), :id => send(:violation_severity_id)}
    super[:violation_coefficient] = {:name => metric_name(:violation_coefficient), :value => send(:violation_coefficient)}
    super[:affected_people_count] = {:name => metric_name(:affected_people_count), :value => send(:affected_people_count)}
  end
end
