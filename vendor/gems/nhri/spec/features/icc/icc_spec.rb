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
    @title = AccreditationRequiredDoc::DocTitles[0]
  end

  scenario "shows list of required icc docs" do
    expect(page_heading).to eq "NHRI ICC Accreditation Documents"
    expect(page).to have_selector ".internal_document .title", :text => @title
  end

  scenario "restrict titles for new docs" do
    page.attach_file("primary_file", upload_document, :visible => false)
    expect(page.all('.template-upload .title select.accreditation_required_doc_title option').map(&:text)).not_to include @title
  end
end
