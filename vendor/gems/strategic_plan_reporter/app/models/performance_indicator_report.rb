class PerformanceIndicatorReport
  include ViewPath

  attr_accessor :performance_indicators, :xml

  def initialize(performance_indicators)
    @performance_indicators = performance_indicators
    generate_xml
  end

  def generate_xml
    @xml = ""
    i = 0
    @xml += blank_performance_indicator if performance_indicators.length.zero?
    performance_indicators.each do |pi|
      @xml += performance_indicator(i==0,pi)
      @xml += ProgressReport.new(pi.media_appearances, pi.projects).to_xml
      i+=1
    end
  end

  def performance_indicator_template(first)
    first ?  template('_inline_performance_indicator.xml') : template('_performance_indicator.xml')
  end

  def blank_performance_indicator
    template('_blank_performance_indicator.xml')
  end

  def performance_indicator(first, performance_indicator)
    performance_indicator_template(first).
      gsub(/performance_indicator/,performance_indicator.indexed_description).
      gsub(/target/,performance_indicator.indexed_target)
  end
end

