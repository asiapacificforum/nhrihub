class PlannedResultReport
  include ViewPath
  attr_accessor :planned_results, :xml

  def initialize(planned_results)
    @planned_results = planned_results
    generate_xml
  end

  def generate_xml
    @xml = ""
    planned_results.each do |pr|
      @xml += planned_result(pr)
      @xml += OutcomeReport.new(pr.outcomes).to_xml
    end
  end

  def planned_result_template
    template('_planned_result.xml')
  end

  def planned_result(planned_result)
    planned_result_template.gsub(/planned_result/,ERB::Util.html_escape(planned_result.indexed_description))
  end

end
