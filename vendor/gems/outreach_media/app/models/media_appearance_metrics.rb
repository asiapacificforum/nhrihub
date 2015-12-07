class MediaAppearanceMetrics < Hash
  attr_accessor :source

  @@metrics = [ :affected_people_count,
               :violation_coefficient,
               :violation_severity,
               :positivity_rating ]

  delegate *@@metrics, :to => :source

  def initialize(source)
    @source = source
    @@metrics.each do |metric|
      super[metric] = send(metric).to_h
    end
  end
end
