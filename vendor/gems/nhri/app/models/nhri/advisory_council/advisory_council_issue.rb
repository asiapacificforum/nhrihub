class Nhri::AdvisoryCouncil::AdvisoryCouncilIssue < ActiveRecord::Base
  include FileConstraints
  ConfigPrefix = 'advisory_council_issue'
  attachment :file
end
