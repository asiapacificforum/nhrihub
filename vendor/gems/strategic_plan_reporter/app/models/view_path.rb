require 'active_support/concern'
module ViewPath
  extend ActiveSupport::Concern

  #included do
    #Root = StrategicPlanReporter::Engine.root
    #TEMPLATE_PATH =  'app/views/strategic_plan_reporter/strategic_plan'
    #TMP_DIR = 'tmp/strategic_plan_report'
  #end

  def to_xml
    xml
  end

  def template(name)
    File.read(Root.join(TEMPLATE_PATH,name))
  end
end
