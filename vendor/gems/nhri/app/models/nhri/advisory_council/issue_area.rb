class Nhri::AdvisoryCouncil::IssueArea < ActiveRecord::Base
  belongs_to :advisory_council_issue
  belongs_to :area
end
