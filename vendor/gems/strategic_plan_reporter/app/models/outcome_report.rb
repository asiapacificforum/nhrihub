class OutcomeReport
  include ViewPath
  attr_accessor :outcomes, :xml

  def initialize(outcomes)
    @outcomes = outcomes
    generate_xml
  end

  def generate_xml
    i = 0
    @xml = ""
    @xml += blank_outcome if @outcomes.length == 0
    @outcomes.each do |o|
      @xml += outcome(i==0,o)
      @xml += ActivityReport.new(o.activities).to_xml
      i+= 1
    end
  end

  def outcome_template(first)
    first ? template('_inline_outcome.xml') : template('_outcome.xml')
  end

  def blank_outcome
    template('_blank_outcome.xml')
  end

  def outcome(first,outcome)
    outcome_template(first).gsub(/outcome/,outcome.indexed_description)
  end

end
