factory_path = Rails.root.join('vendor','gems',"strategic_plan_reporter",'spec','factories')
FactoryGirl.definition_file_paths << factory_path

StrategicPlanReport::Root = ViewPath::Root = StrategicPlanReporter::Engine.root
StrategicPlanReport::TEMPLATE_PATH = ViewPath::TEMPLATE_PATH = 'app/views/strategic_plan_reporter/strategic_plan'
StrategicPlanReport::TMP_DIR = Rails.root.join('tmp','strategic_plan_report')
