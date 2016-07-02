require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/advisory_council/advisory_council_minutes_context_admin_spec_helper'
require 'shared_behaviours/file_admin_behaviour'

feature "advisory council minutes admin" do
  include AdvisoryCouncilMinutesContextAdminSpecHelper
  it_should_behave_like "file admin"
end
