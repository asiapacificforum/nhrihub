require Rails.root.join('app', 'domain_models', 'report_utilities', 'view_path').to_s

StrategicPlanReport::Root = ViewPath::Root = StrategicPlanReporter::Engine.root
StrategicPlanReport::TEMPLATE_PATH = ViewPath::TEMPLATE_PATH = 'app/views/strategic_plan_reporter/strategic_plan'
StrategicPlanReport::TMP_DIR = Rails.root.join('tmp','strategic_plan_report')
