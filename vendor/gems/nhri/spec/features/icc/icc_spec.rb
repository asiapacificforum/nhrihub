require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/icc/icc_spec_helper'
require_relative '../../helpers/icc/icc_setup_helper'


feature "show icc index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IccSpecHelper
  include IccSetupHelper

  before do
    setup_database
    visit nhri_icc_index_path(:en)
  end

  scenario "shows list of required icc docs" do
    expect(page_heading).to eq "ICC"
    expect(page).to have_selector "#required_docs .required_doc .title", :text => "Statement of Compliance"
  end
end
