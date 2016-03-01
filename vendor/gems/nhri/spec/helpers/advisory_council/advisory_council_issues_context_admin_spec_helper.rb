require 'rspec/core/shared_context'
require_relative './advisory_council_issues_admin_spec_helper'

module AdvisoryCouncilIssuesContextAdminSpecHelper
  include AdvisoryCouncilIssuesAdminSpecHelper
  extend RSpec::Core::SharedContext
  def model
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue
  end

  def filesize_selector
    '#advisory_council_issues_filesize'
  end

  def filetypes_selector
    '#advisory_council_issues_filetypes'
  end

  def admin_page
    nhri_admin_path('en')
  end
end
