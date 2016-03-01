class Nhri::AdvisoryCouncil::AdvisoryCouncilIssue < ActiveRecord::Base
  include FileConstraints
  ConfigPrefix = 'nhri.advisory_council_issue'
  attachment :file
end
