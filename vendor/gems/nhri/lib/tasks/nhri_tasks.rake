def sub_modules
  [ "advisory_council:terms_of_reference",
    "advisory_council:membership",
    "advisory_council:meeting_minutes",
    "advisory_council:issues",
    "human_rights_indicators",
    "accreditation:internal_documents",
    "accreditation:reference_documents" ]
end

namespace :nhri do
  desc "depopulate nhri tables"
  task :depopulate => :environment do
    sub_modules.each do |sub_module|
      Rake::Task["nhri:#{sub_module}:depopulate"].invoke
    end #/sub_modules.each
  end


  desc "populate all nhri modules"
  task :populate => :environment do
    sub_modules.each do |sub_module|
      Rake::Task["nhri:#{sub_module}:populate"].invoke
    end #/sub_modules.each
  end #/task
end #/namespace
