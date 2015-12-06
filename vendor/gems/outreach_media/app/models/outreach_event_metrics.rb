class OutreachEventMetrics < Hash
  attr_accessor :source
  delegate :affected_people_count,
           :audience_name,
           :participant_count,
           :to => :source

  def metric_name(key)
    I18n.t("activerecord.attributes.outreach_event."+key.to_s)
  end

  def initialize(source)
    @source = source
    super[:affected_people_count] = {:name => metric_name(:affected_people_count), :value => send(:affected_people_count)}
    super[:audience_name]= {:name => metric_name(:audience_name), :value => send(:audience_name)}
    super[:participant_count]= {:name => metric_name(:participant_count), :value => send(:participant_count)}
    #:description
    #:impact_rating_id
    #:audience_type_id
  end
end
