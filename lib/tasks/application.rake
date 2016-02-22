desc "populate the entire application"
task :populate => ["corporate_services:populate", "outreach_media:populate", "nhri:populate"]
