class Nhri::AdvisoryCouncil::IssueSubarea < ActiveRecord::Base
  belongs_to :advisory_council_issue
  belongs_to :subarea
end
