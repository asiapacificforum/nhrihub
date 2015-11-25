# factory needed in production in order to populate media appearance database
factory_path = Rails.root.join('vendor','gems','outreach_media','spec','factories')
FactoryGirl.definition_file_paths << factory_path
if Rails.env.development? || Rails.env.test? || Rails.env.jstest?
  Rails.application.config.assets.paths << Rails.root.join('vendor', 'gems', 'outreach_media', 'spec', 'support', 'javascript')
end
