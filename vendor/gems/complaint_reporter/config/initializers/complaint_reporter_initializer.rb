factory_path = Rails.root.join('vendor','gems',"complaint_reporter",'spec','factories')
FactoryGirl.definition_file_paths << factory_path

ComplaintReport::Root = ComplaintReporter::Engine.root
ComplaintReport::TEMPLATE_PATH = 'app/views/complaint_reporter/complaints'
ComplaintReport::TMP_DIR = Rails.root.join('tmp','complaint')
