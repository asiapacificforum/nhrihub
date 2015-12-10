class OutreachEventMetrics < Hash
  #attr_accessor :source
  #@@metrics = [ :affected_people_count,
                #:audience_type,
                #:audience_name,
                #:description,
                #:participant_count]

  #delegate *@@metrics,:to => :source

  #def initialize(source)
    #@source = source
    #@@metrics.each do |metric|
      #super[metric] = send(metric).to_h
    #end
    ##:description
    ##:impact_rating_id
    ##:audience_type_id
  #end
end
