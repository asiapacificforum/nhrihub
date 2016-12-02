factory_path = Rails.root.join('vendor','gems',"strategic_plan_reporter",'spec','factories')
FactoryGirl.definition_file_paths << factory_path

Root = StrategicPlanReporter::Engine.root
TEMPLATE_PATH =  'app/views/strategic_plan_reporter/strategic_plan'
TMP_DIR = 'tmp/strategic_plan_report'
