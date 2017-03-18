require Rails.root.join('app', 'domain_models', 'report_utilities', 'word_report').to_s

class StrategicPlanReport < WordReport
  include ViewPath
  attr_accessor :strategic_plan
  def initialize(strategic_plan)
    @strategic_plan = strategic_plan
    super() # no args passed!
  end

  def generate_word_doc
    @word_doc = head
    strategic_plan.strategic_priorities.each do |strategic_priority|
      @word_doc += StrategicPriorityReport.new(strategic_priority).to_xml
    end
    @word_doc += tail
  end

  def head
    template('_head.xml')
  end

  def tail
    template('_tail.xml')
  end

end
