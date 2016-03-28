require 'rspec/core/shared_context'
require_relative './file_monitor_admin_spec_helper'

module FileMonitorContextAdminSpecHelper
  include FileMonitorAdminSpecHelper
  extend RSpec::Core::SharedContext
  def model
    Nhri::FileMonitor
  end

  def filesize_selector
    '#file_monitor_filesize'
  end

  def filetypes_selector
    '#file_monitor_filetypes'
  end

  def admin_page
    nhri_admin_path('en')
  end
end
