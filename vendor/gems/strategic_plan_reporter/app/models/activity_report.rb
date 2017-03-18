class ActivityReport
  include ViewPath
  attr_accessor :activities, :xml

  def initialize(activities)
    @activities = activities
    generate_xml
  end

  def generate_xml
    @xml = ""
    i = 0
    @xml += blank_activity if activities.length == 0
    activities.each do |a|
      @xml += activity(i==0,a)
      @xml += PerformanceIndicatorReport.new(a.performance_indicators).to_xml
      i+=1
    end
  end

  def blank_activity
    template('_blank_activity.xml')
  end

  def activity_template(first)
    first ? template('_inline_activity.xml') : template('_activity.xml')
  end

  def activity(first,activity)
    activity_template(first).gsub(/activity/,ERB::Util.html_escape(activity.indexed_description))
  end
end
