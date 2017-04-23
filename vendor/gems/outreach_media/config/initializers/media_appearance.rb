# factory needed in production in order to populate media appearance database
if Rails.env.development? || Rails.env.test? || Rails.env.jstest?
  Rails.application.config.assets.paths << Rails.root.join('vendor', 'gems', 'outreach_media', 'spec', 'support', 'javascript')
end
