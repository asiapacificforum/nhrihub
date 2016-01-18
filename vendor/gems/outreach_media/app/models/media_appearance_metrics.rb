class MediaAppearanceMetrics < Hash
  attr_accessor :source
  delegate :affected_people_count,
           :violation_coefficient,
           :violation_severity_id,
           :violation_severity_rank_text,
           :violation_severity_rank,
           :violation_severity,
           :positivity_rating_id,
           :positivity_rating_rank_text,
           :positivity_rating_rank,
           :positivity_rating,
           :to => :source

  #def metric_name(key)
    #I18n.t("activerecord.attributes.media_appearance."+key.to_s)
  #end

  def initialize(source)
    @source = source
    super[:positivity_rating] = {:rank => send(:positivity_rating_rank), :value => send(:positivity_rating_rank_text)}
    super[:violation_severity] = {:rank => send(:violation_severity_rank), :value => send(:violation_severity_rank_text)}
    super[:violation_coefficient] = {:value => send(:violation_coefficient)}
    super[:affected_people_count] = {:value => send(:affected_people_count)}
  end
end
