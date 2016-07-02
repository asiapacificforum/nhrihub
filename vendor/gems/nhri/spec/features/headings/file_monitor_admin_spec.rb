require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/headings/file_monitor_context_admin_spec_helper'
require 'shared_behaviours/file_admin_behaviour'

feature "file monitor admin" do
  include FileMonitorContextAdminSpecHelper
  it_should_behave_like "file admin"
end
