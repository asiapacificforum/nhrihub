require 'rspec/core/shared_context'

module AdvisoryCouncilIssuesContextAdminSpecHelper
  extend RSpec::Core::SharedContext
  def model
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue
  end

  def filesize_selector
    '#advisory_council_issues_filesize'
  end

  def filesize_context
    page.find( '#advisory_council_issues_filesize')
  end

  def filetypes_selector
    '#advisory_council_issues_filetypes'
  end

  def filetypes_context
    page.find('#advisory_council_issues_filetypes')
  end

  def admin_page
    nhri_admin_path('en')
  end
end
