class StrategicPriorityReport
  include ViewPath
  attr_accessor :strategic_priority

  def initialize(strategic_priority)
    @strategic_priority = strategic_priority
  end

  def strategic_priority_snippet(strategic_priority)
    @strategic_priority_template ||= strategic_priority_template
    @strategic_priority_template.gsub(/strategic_priority/, "Strategic Priority #{strategic_priority.index}: #{ERB::Util.html_escape(strategic_priority.description)}")
  end

  def strategic_priority_template
    template('_strategic_priority.xml')
  end

  def to_xml
    xml = strategic_priority_snippet(strategic_priority)
    xml += PlannedResultReport.new(strategic_priority.planned_results).to_xml if strategic_priority.planned_results
  end
end
