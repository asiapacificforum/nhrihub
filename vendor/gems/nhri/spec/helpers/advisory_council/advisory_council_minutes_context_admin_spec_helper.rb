require 'rspec/core/shared_context'
require_relative './advisory_council_minutes_admin_spec_helper'

module AdvisoryCouncilMinutesContextAdminSpecHelper
  extend RSpec::Core::SharedContext
  def model
    Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes
  end

  def filesize_selector
    '#advisory_council_minutes_filesize'
  end

  def filesize_context
    page.find('#advisory_council_minutes_filesize')
  end

  def filetypes_selector
    '#advisory_council_minutes_filetypes'
  end

  def filetypes_context
    page.find('#advisory_council_minutes_filetypes')
  end

  def admin_page
    nhri_admin_path('en')
  end
end
